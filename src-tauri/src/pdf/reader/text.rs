use std::collections::HashMap;

use pdfium_render::prelude::{PdfDocument, PdfPoints, PdfRect};

use crate::pdf::{DocumentId, TextItem};

pub fn get_text_by_page(
    documents: &HashMap<DocumentId, PdfDocument>,
    id: &DocumentId,
    page_index: u16,
) -> Result<Vec<TextItem>, String> {
    let document = documents.get(id).ok_or("Document not found")?;

    let page = document
        .pages()
        .get(page_index)
        .map_err(|e| e.to_string())?;

    let text_page = page.text().map_err(|e| e.to_string())?;

    let page_height = page.height().value;

    let mut items = Vec::new();
    let mut current_word = String::new();
    let mut current_bbox: Option<PdfRect> = None;

    let chars = text_page.chars();

    for i in 0..chars.len() {
        let ch = chars.get(i).map_err(|e| e.to_string())?;
        let unicode = match ch.unicode_char() {
            Some(c) => c,
            None => continue,
        };

        let rect = ch
            .tight_bounds()
            .or_else(|_| ch.loose_bounds())
            .unwrap_or(PdfRect::new(
                PdfPoints::new(0.0),
                PdfPoints::new(0.0),
                PdfPoints::new(0.0),
                PdfPoints::new(0.0),
            ));

        if unicode.is_whitespace() {
            flush_word(
                &mut items,
                &mut current_word,
                &mut current_bbox,
                page_height,
            );
            continue;
        }

        current_word.push(unicode);

        current_bbox = Some(match current_bbox {
            Some(existing) => union_rects(&existing, &rect),
            None => rect,
        });
    }

    flush_word(
        &mut items,
        &mut current_word,
        &mut current_bbox,
        page_height,
    );

    Ok(items)
}

fn union_rects(r1: &PdfRect, r2: &PdfRect) -> PdfRect {
    let left = f32::min(r1.left().value, r2.left().value);
    let right = f32::max(r1.right().value, r2.right().value);
    let top = f32::max(r1.top().value, r2.top().value);
    let bottom = f32::min(r1.bottom().value, r2.bottom().value);
    PdfRect::new(
        PdfPoints::new(bottom),
        PdfPoints::new(left),
        PdfPoints::new(top),
        PdfPoints::new(right),
    )
}

fn flush_word(
    items: &mut Vec<TextItem>,
    word: &mut String,
    bbox: &mut Option<PdfRect>,
    page_height: f32,
) {
    if word.is_empty() {
        return;
    }

    if let Some(rect) = bbox.take() {
        // PDF → DOM coordinate transform
        let x = rect.left().value;
        let y = page_height - rect.top().value;

        items.push(TextItem {
            text: word.clone(),
            x,
            y,
            width: rect.width().value,
            height: rect.height().value,
        });
    }

    word.clear();
}
