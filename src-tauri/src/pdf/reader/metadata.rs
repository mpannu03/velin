use std::collections::HashMap;

use pdfium_render::prelude::PdfDocument;

use crate::pdf::{DocumentId, PdfInfo};

pub fn get_info(
    documents: &HashMap<DocumentId, PdfDocument>,
    id: &DocumentId,
) -> Result<PdfInfo, String> {
    let document = documents
        .get(id)
        .ok_or("Document not found")?;

    let page_count = document.pages().len();
    let pdf_info = PdfInfo::new(page_count);
    
    Ok(pdf_info)
}