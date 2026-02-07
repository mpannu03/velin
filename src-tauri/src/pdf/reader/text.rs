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

    let mut items = Vec::new();
    let mut current_line = String::new();
    let mut current_bbox: Option<PdfRect> = None;

    let chars = text_page.chars();

    for i in 0..chars.len() {
        let ch = chars.get(i).map_err(|e| e.to_string())?;

        let unicode = match ch.unicode_char() {
            Some(c) => c,
            None => continue,
        };

        // Use loose_bounds for more consistent selection box heights across characters
        let rect = ch.loose_bounds().unwrap_or(PdfRect::new(
            PdfPoints::new(0.0),
            PdfPoints::new(0.0),
            PdfPoints::new(0.0),
            PdfPoints::new(0.0),
        ));

        // Detect line break: significantly different vertical position
        let is_new_line = if let Some(ref prev_bbox) = current_bbox {
            let prev_bottom = prev_bbox.bottom().value;
            let current_bottom = rect.bottom().value;
            let height = rect.height().value;

            // If the jump is more than 30% of the character height, consider it a new line
            (current_bottom - prev_bottom).abs() > height * 0.3
        } else {
            false
        };

        if is_new_line {
            flush_text_item(
                &mut items,
                &mut current_line,
                &mut current_bbox,
                page_height,
            );
        }

        current_line.push(unicode);
        current_bbox = Some(match current_bbox {
            Some(existing) => union_rects(&existing, &rect),
            None => rect,
        });
    }

    flush_text_item(
        &mut items,
        &mut current_line,
        &mut current_bbox,
        page_height,
    );

    Ok(PageText {
        items,
        width: page_width,
        height: page_height,
    })
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

fn flush_text_item(
    items: &mut Vec<TextItem>,
    text_content: &mut String,
    bbox: &mut Option<PdfRect>,
    page_height: f32,
) {
    if text_content.trim().is_empty() {
        return;
    }

    if let Some(rect) = bbox.take() {
        let x = rect.left().value;
        let y = page_height - rect.top().value;

        items.push(TextItem {
            text: text_content.clone(),
            x,
            y,
            width: rect.width().value,
            height: rect.height().value,
        });
    }

    text_content.clear();
}
