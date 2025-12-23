use pdfium_render::prelude::*;

/// Backend abstraction for PDF handling
pub enum PdfBackend {
    Pdfium(PdfiumBackend),
}

/// Pdfium-specific backend state
pub struct PdfiumBackend {
    pub library: Pdfium,
    pub document: PdfDocument<'static>,
}
