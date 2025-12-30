use std::{collections::HashMap, path::Path};
use pdfium_render::prelude::{PdfDocument, PdfRenderConfig, Pdfium};
use serde::Serialize;

use crate::pdf::DocumentId;

#[derive(Serialize)]
pub struct RenderedPage {
    pub width: i32,
    pub height: i32,
    pub pixels: Vec<u8>,
}

pub fn open<'a>(
    id: DocumentId,
    path: &Path,
    documents: &mut HashMap<DocumentId, PdfDocument<'a>>,
    pdfium: &'a Pdfium,
) -> Result<(), String> {
    let document = pdfium
        .load_pdf_from_file(path, None)
        .map_err(|e| format!("Failed to open PDF: {}", e))?;
    documents.insert(id, document);
    Ok(())
}

pub fn close(
    documents: &mut HashMap<DocumentId, PdfDocument>,
    id: &DocumentId,
) -> Result<(), String> {
    documents
        .remove(id)
        .ok_or("Document not found".to_string())?;
    Ok(())
}

pub fn render_page(
    documents: &HashMap<DocumentId, PdfDocument>,
    id: &DocumentId,
    page_index: u16,
    target_width: i32,
) -> Result<RenderedPage, String> {
    let document = documents
        .get(id)
        .ok_or("Document not found")?;

    let page = document
        .pages()
        .get(page_index)
        .map_err(|e| format!("Failed to get page: {e}"))?;

    let config = PdfRenderConfig::new()
        .set_target_width(target_width);

    let bitmap = page.render_with_config(&config)
        .map_err(|e| format!("Rendering Error: {}", e))?;

    let rendered_page = RenderedPage{
        width: bitmap.width(),
        height: bitmap.height(),
        pixels: bitmap.as_raw_bytes(),
    };

    Ok(rendered_page)
}
