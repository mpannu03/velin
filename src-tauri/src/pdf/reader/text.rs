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
    let mut current_line_chars = Vec::new();
    let mut last_bottom: Option<f32> = None;

    let chars = text_page.chars();

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

        let current_bottom = rect.bottom().value;
        let current_height = rect.height().value;

        // Detect line break: vertical jump > 10% of height
        if let Some(prev_bottom) = last_bottom {
            if (current_bottom - prev_bottom).abs() > current_height * 0.1 {
                flush_line_as_chars(&mut items, &mut current_line_chars, page_height);
            }
        }

        current_line_chars.push((unicode, rect));
        last_bottom = Some(current_bottom);
    }

    flush_line_as_chars(&mut items, &mut current_line_chars, page_height);

    Ok(PageText {
        items,
        width: page_width,
        height: page_height,
    })
}

fn flush_line_as_chars(
    items: &mut Vec<TextItem>,
    line_chars: &mut Vec<(char, PdfRect)>,
    page_height: f32,
) {
    if line_chars.is_empty() {
        return;
    }

    // Determine vertical metrics for normalization across the entire line
    let mut max_top = f32::MIN;
    let mut min_bottom = f32::MAX;

    for (_, rect) in line_chars.iter() {
        max_top = f32::max(max_top, rect.top().value);
        min_bottom = f32::min(min_bottom, rect.bottom().value);
    }

    // Normalized Y and Height for this line
    let y = page_height - max_top;
    let height = max_top - min_bottom;

    // Flush each character as an individual TextItem with normalized Y/Height
    for (unicode, rect) in line_chars.drain(..) {
        items.push(TextItem {
            text: unicode.to_string(),
            x: rect.left().value,
            y,
            width: rect.width().value,
            height,
        });
    }
}
