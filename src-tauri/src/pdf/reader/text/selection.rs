use std::collections::HashMap;

use pdfium_render::prelude::{PdfDocument, PdfPoints, PdfRect};
use serde::Serialize;

use crate::pdf::DocumentId;

#[derive(Debug, Clone, Serialize)]
pub struct TextItem {
    pub text: String,
    pub x: f32,
    pub y: f32,
    pub width: f32,
    pub height: f32,
    // pub font_size: f32,
    // pub font_name: String,
    // pub font_weight: u32,
}

#[derive(Debug, Clone, Serialize)]
pub struct PageText {
    pub items: Vec<TextItem>,
    pub width: f32,
    pub height: f32,
}

// pub fn get_text_by_page(
//     documents: &HashMap<DocumentId, PdfDocument>,
//     id: &DocumentId,
//     page_index: u16,
// ) -> Result<PageText, String> {
//     let document = documents.get(id).ok_or("Document not found")?;

//     let page = document
//         .pages()
//         .get(page_index)
//         .map_err(|e| e.to_string())?;

//     let text_page = page.text().map_err(|e| e.to_string())?;

//     let page_height = page.height().value;
//     let page_width = page.width().value;

//     let mut items = Vec::new();

//     for ch in text_page.chars().iter() {
//         // Safe unicode extraction
//         let text = match ch.unicode_string() {
//             Some(s) => match s.chars().next() {
//                 Some(c) => c,
//                 None => continue, // skip empty strings
//             },
//             None => continue, // skip if no unicode
//         };

//         // Safe bounds extraction
//         let bounds = match ch.loose_bounds() {
//             Ok(b) => b,
//             Err(_) => continue, // skip character if bounds fail
//         };

//         let font_weight = ch.font_weight().map(pdf_font_weight_to_u32).unwrap_or(400); // default normal weight

//         items.push(TextItem {
//             text,
//             x: bounds.left().value,
//             y: page_height - bounds.top().value,
//             width: bounds.width().value,
//             height: bounds.height().value,
//             font_size: ch.scaled_font_size().value,
//             font_name: ch.font_name(),
//             font_weight,
//         });
//     }

//     Ok(PageText {
//         items,
//         width: page_width,
//         height: page_height,
//     })
// }

// fn pdf_font_weight_to_u32(font_weight: PdfFontWeight) -> u32 {
//     match font_weight {
//         PdfFontWeight::Weight100 => 100,
//         PdfFontWeight::Weight200 => 200,
//         PdfFontWeight::Weight300 => 300,
//         PdfFontWeight::Weight400Normal => 400,
//         PdfFontWeight::Weight500 => 500,
//         PdfFontWeight::Weight600 => 600,
//         PdfFontWeight::Weight700Bold => 700,
//         PdfFontWeight::Weight800 => 800,
//         PdfFontWeight::Weight900 => 900,
//         PdfFontWeight::Custom(other) => other,
//     }
// }

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
