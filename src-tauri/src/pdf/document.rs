use serde::Serialize;

/// Unique identifier for an opened PDF document
pub type DocumentId = String;

#[derive(Debug, Clone, Serialize)]
pub struct PdfInfo {
    pub page_count: u16
}

impl PdfInfo {
    pub fn new(page_count: u16) -> Self {
        Self { page_count }
    }
}