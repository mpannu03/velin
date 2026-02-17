use std::collections::HashMap;

use pdfium_render::prelude::{PdfDocument, PdfPoints, PdfRect};
use serde::Serialize;

use crate::pdf::DocumentId;

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

#[derive(Serialize)]
pub struct SearchHit {
    pub page: u16,
    pub start: usize,
    pub end: usize,
    pub rects: Vec<SearchHitRect>,
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
