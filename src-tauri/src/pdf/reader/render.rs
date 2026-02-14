use image::{ImageBuffer, Rgba};
use pdfium_render::prelude::{PdfDocument, PdfRenderConfig, Pdfium};
use serde::Serialize;
use std::{collections::HashMap, io::Cursor, path::Path};

use crate::pdf::DocumentId;

const PREVIEW_WIDTH: i32 = 100;

#[derive(Debug, Serialize)]
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
    let document = documents.get(id).ok_or("Document not found")?;

    let page = document
        .pages()
        .get(page_index)
        .map_err(|e| format!("Failed to get page: {e}"))?;

    let config = PdfRenderConfig::new().set_target_width(target_width);

    let bitmap = page
        .render_with_config(&config)
        .map_err(|e| format!("Rendering Error: {}", e))?;

    let rendered_page = RenderedPage {
        width: bitmap.width(),
        height: bitmap.height(),
        pixels: bitmap.as_raw_bytes(),
    };

    Ok(rendered_page)
}

pub fn generate_preview(
    documents: &HashMap<DocumentId, PdfDocument>,
    id: &DocumentId,
    save_path: Option<impl AsRef<Path>>,
) -> Result<Vec<u8>, String> {
    let document = documents.get(id).ok_or("Document not found")?;

    let page = document
        .pages()
        .get(0)
        .map_err(|e| format!("Failed to get page: {e}"))?;

    let config = PdfRenderConfig::new().set_target_width(PREVIEW_WIDTH);
    let bitmap = page
        .render_with_config(&config)
        .map_err(|e| format!("Rendering Error: {e}"))?;

    let png_bytes = rgba_to_png_bytes(bitmap.as_raw_bytes(), bitmap.width(), bitmap.height())?;

    if let Some(path) = save_path {
        let path = path.as_ref();
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent).map_err(|e| e.to_string())?;
        }
        std::fs::write(path, &png_bytes).map_err(|e| e.to_string())?;
    }

    Ok(png_bytes)
}

pub fn rgba_to_png_bytes(pixels: Vec<u8>, width: i32, height: i32) -> Result<Vec<u8>, String> {
    let img: ImageBuffer<Rgba<u8>, _> = ImageBuffer::from_raw(width as u32, height as u32, pixels)
        .ok_or("Failed to create image buffer")?;

    let mut png_bytes: Vec<u8> = Vec::new();

    img.write_to(&mut Cursor::new(&mut png_bytes), image::ImageFormat::Png)
        .map_err(|e| e.to_string())?;

    Ok(png_bytes)
}

#[cfg(test)]
mod tests {
    use super::*;
    use pdfium_render::prelude::Pdfium;
    use std::{collections::HashMap, path::PathBuf};

    #[test]
    fn test_render_close_not_found() {
        let mut documents = HashMap::new();
        let id = "non_existent".to_string();

        let result = close(&mut documents, &id);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "Document not found");
    }

    #[test]
    fn test_render_page_not_found() {
        let documents = HashMap::new();
        let id = "non_existent".to_string();

        let result = render_page(&documents, &id, 0, 800);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "Document not found");
    }

    #[test]
    fn test_render_open_invalid_path() {
        let pdfium = Pdfium::default();
        let mut documents = HashMap::new();
        let id = "test".to_string();
        let path = PathBuf::from("non_existent_file.pdf");

        let result = open(id, &path, &mut documents, &pdfium);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("Failed to open PDF"));
    }
}
