use std::collections::HashMap;

use pdfium_render::prelude::PdfDocument;

use crate::pdf::{DocumentId, PdfInfo};

pub fn get_info(
    documents: &HashMap<DocumentId, PdfDocument>,
    id: &DocumentId,
) -> Result<PdfInfo, String> {
    let document = documents.get(id).ok_or("Document not found")?;

    let page_count = document.pages().len();

    // Get dimensions of the first page to determine aspect ratio
    let (width, height) = if page_count > 0 {
        let page = document.pages().get(0).map_err(|e| e.to_string())?;
        (page.width().value, page.height().value)
    } else {
        (612.0, 792.0) // Default to Letter size if empty
    };

    let pdf_info = PdfInfo::new(page_count, width, height);

    Ok(pdf_info)
}
