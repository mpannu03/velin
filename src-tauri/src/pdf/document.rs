use serde::Serialize;

/// Unique identifier for an opened PDF document
pub type DocumentId = String;

#[derive(Debug, Clone, Serialize)]
pub struct PdfInfo {
    pub page_count: u16,
    pub width: f32,
    pub height: f32,
}

impl PdfInfo {
    pub fn new(page_count: u16, width: f32, height: f32) -> Self {
        Self {
            page_count,
            width,
            height,
        }
    }
}

#[derive(Debug, Clone, Serialize)]
pub struct Bookmark {
    pub title: String,
    pub page_index: Option<u16>,
    pub children: Vec<Bookmark>,
}

#[derive(Debug, Clone, Serialize, Default)]
pub struct Bookmarks {
    pub items: Vec<Bookmark>,
}
