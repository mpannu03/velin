use std::collections::HashMap;

use pdfium_render::prelude::{PdfDocument, PdfPoints, PdfRect};
use serde::Serialize;

use crate::pdf::{DocumentId, TextItem};

#[derive(Debug, Clone, Serialize)]
pub struct PageText {
    pub items: Vec<TextItem>,
    pub width: f32,
    pub height: f32,
}

pub struct TextCharMeta {
    pub page: u16,
    pub char_index: usize,
    pub rect: PdfRect,
}

pub struct PageSearchText {
    pub page: u16,
    pub text: String,
    pub char_map: Vec<TextCharMeta>,
    pub width: f32,
    pub height: f32,
}

pub struct SearchIndex {
    pub pages: Vec<PageSearchText>,
}

#[derive(Debug, Clone, Serialize)]
pub struct SearchHitRect {
    pub x: f32,
    pub y: f32,
    pub w: f32,
    pub h: f32,
}

#[derive(serde::Serialize)]
pub struct SearchHit {
    pub page: u16,
    pub start: usize,
    pub end: usize,
    pub rects: Vec<SearchHitRect>,
}

pub fn get_text_by_page(
    documents: &HashMap<DocumentId, PdfDocument>,
    id: &DocumentId,
    page_index: u16,
) -> Result<PageText, String> {
    let document = documents.get(id).ok_or("Document not found")?;

    let page = document
        .pages()
        .get(page_index)
        .map_err(|e| e.to_string())?;

    let text_page = page.text().map_err(|e| e.to_string())?;

    let page_height = page.height().value;
    let page_width = page.width().value;

    let mut items: Vec<TextItem> = Vec::new();
    let chars = text_page.chars();

    let mut current_fragment: Option<TextItem> = None;
    let spacing_threshold = 2.0;

    for i in 0..chars.len() {
        let ch = chars.get(i).map_err(|e| e.to_string())?;
        let unicode = match ch.unicode_char() {
            Some(c) => c,
            None => continue,
        };

        let rect = ch.loose_bounds().unwrap_or(PdfRect::new(
            PdfPoints::new(0.0),
            PdfPoints::new(0.0),
            PdfPoints::new(0.0),
            PdfPoints::new(0.0),
        ));

        let x = rect.left().value;
        let y = page_height - rect.top().value;
        let width = rect.width().value;
        let height = rect.height().value;

        if let Some(mut fragment) = current_fragment.take() {
            let same_line = (y - fragment.y).abs() < 0.1 && (height - fragment.height).abs() < 0.1;
            let is_near = x >= fragment.x + fragment.width - spacing_threshold
                && x <= fragment.x + fragment.width + spacing_threshold;

            if same_line && is_near {
                fragment.text.push(unicode);
                fragment.width = x + width - fragment.x;
                current_fragment = Some(fragment);
            } else {
                items.push(fragment);
                current_fragment = Some(TextItem {
                    text: unicode.to_string(),
                    x,
                    y,
                    width,
                    height,
                });
            }
        } else {
            current_fragment = Some(TextItem {
                text: unicode.to_string(),
                x,
                y,
                width,
                height,
            });
        }
    }

    if let Some(fragment) = current_fragment {
        items.push(fragment);
    }

    Ok(PageText {
        items,
        width: page_width,
        height: page_height,
    })
}

fn build_search_index(document: &PdfDocument) -> Result<SearchIndex, String> {
    let mut pages = Vec::new();

    for (page_index, page) in document.pages().iter().enumerate() {
        let text_page = page.text().map_err(|e| e.to_string())?;
        let chars = text_page.chars();

        let mut text = String::new();
        let mut char_map = Vec::new();

        for i in 0..chars.len() {
            let ch = chars.get(i).map_err(|e| e.to_string())?;

            let unicode = match ch.unicode_char() {
                Some(c) => c,
                None => continue,
            };

            let rect = ch.loose_bounds().unwrap_or(PdfRect::new(
                PdfPoints::new(0.0),
                PdfPoints::new(0.0),
                PdfPoints::new(0.0),
                PdfPoints::new(0.0),
            ));

            text.push(unicode);
            char_map.push(TextCharMeta {
                page: page_index as u16,
                char_index: i,
                rect,
            });
        }

        pages.push(PageSearchText {
            page: page_index as u16,
            text,
            char_map,
            width: page.width().value,
            height: page.height().value,
        });
    }

    Ok(SearchIndex { pages })
}

pub fn search_document(
    documents: &HashMap<DocumentId, PdfDocument>,
    id: &DocumentId,
    query: &str,
) -> Result<Vec<SearchHit>, String> {
    let document = documents.get(id).ok_or("Document not found")?;
    let index = build_search_index(document)?;

    let mut hits = Vec::new();

    for page in &index.pages {
        let page_text = &page.text;
        let page_index = page.page;

        let char_count = query.chars().count();
        let byte_to_char: std::collections::HashMap<usize, usize> = page_text
            .char_indices()
            .enumerate()
            .map(|(c_idx, (b_idx, _))| (b_idx, c_idx))
            .collect();

        let mut start_search = 0;
        while let Some(pos) = page_text[start_search..].find(query) {
            let start_byte = start_search + pos;
            let end_byte = start_byte + query.len();

            if let Some(&start_char_idx) = byte_to_char.get(&start_byte) {
                let mut rects = Vec::new();
                for i in 0..char_count {
                    if let Some(meta) = page.char_map.get(start_char_idx + i) {
                        rects.push(SearchHitRect {
                            x: meta.rect.left().value,
                            y: page.height - meta.rect.top().value,
                            w: meta.rect.width().value,
                            h: meta.rect.height().value,
                        });
                    }
                }

                hits.push(SearchHit {
                    page: page_index,
                    start: start_char_idx,
                    end: start_char_idx + char_count,
                    rects,
                });
            }
            start_search = end_byte;
        }
    }

    Ok(hits)
}
