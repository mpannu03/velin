use pdfium_render::prelude::{PdfBitmap, PdfBitmapFormat, PdfDocument, PdfRenderConfig, Pdfium};
use serde::Serialize;
use std::{collections::HashMap, path::Path};
use webp::Encoder;

use crate::pdf::DocumentId;

const PREVIEW_WIDTH: i32 = 100;

#[derive(Debug, Serialize)]
pub struct RenderedPage {
    pub width: i32,
    pub height: i32,
    pub pixels: Vec<u8>,
}

#[derive(Debug, Serialize)]
pub struct RenderedTile {
    pub x: i32,
    pub y: i32,
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

    let width = bitmap.width();
    let height = bitmap.height();

    let webp_bytes = bgra_to_webp(&bitmap.as_raw_bytes(), width as u32, height as u32, 80.0)?;

    let rendered_page = RenderedPage {
        width: width as i32,
        height: height as i32,
        pixels: webp_bytes,
    };

    Ok(rendered_page)
}

pub fn render_tile(
    documents: &HashMap<DocumentId, PdfDocument>,
    id: &DocumentId,
    page_index: u16,

    // FULL PAGE render width (not tile width!)
    target_width: i32,

    // Tile position in RENDER PIXELS (Top-Left origin, screen-space)
    tile_x: i32,
    tile_y: i32,
    tile_width: i32,
    tile_height: i32,
) -> Result<RenderedTile, String> {
    let document = documents.get(id).ok_or("Document not found")?;

    let page = document
        .pages()
        .get(page_index)
        .map_err(|e| format!("Failed to get page: {e}"))?;

    // 🚀 THE FIX: If set_target_width is used, .clip() expects pixel coordinates
    // in the final rendered buffer (Top-Left origin).
    // NO PDF MATH NEEDED. Just use tile_x, tile_y directly.

    let config = PdfRenderConfig::new().set_target_width(target_width).clip(
        tile_x,
        tile_y,
        tile_x + tile_width,
        tile_y + tile_height,
    );

    // render_with_config automatically handles translation when clipping is applied.
    let bitmap = page
        .render_with_config(&config)
        .map_err(|e| format!("Rendering Error: {e}"))?;

    let webp_bytes = bgra_to_webp(
        &bitmap.as_raw_bytes(),
        bitmap.width() as u32,
        bitmap.height() as u32,
        85.0, // Sharp quality for tiles
    )?;

    Ok(RenderedTile {
        x: tile_x,
        y: tile_y,
        width: bitmap.width() as i32,
        height: bitmap.height() as i32,
        pixels: webp_bytes,
    })
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

    let webp_bytes = rgba_to_webp(
        &bitmap.as_raw_bytes(),
        bitmap.width() as u32,
        bitmap.height() as u32,
        90.0,
    )?;

    if let Some(path) = save_path {
        let path = path.as_ref();
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent).map_err(|e| e.to_string())?;
        }
        std::fs::write(path, &webp_bytes).map_err(|e| e.to_string())?;
    }

    Ok(webp_bytes)
}

fn bgra_to_webp(bgra: &[u8], width: u32, height: u32, quality: f32) -> Result<Vec<u8>, String> {
    // PDFium returns BGRA, WebP wants RGBA. Swap R and B.
    let mut rgba = Vec::with_capacity(bgra.len());
    for chunk in bgra.chunks_exact(4) {
        rgba.push(chunk[2]); // R
        rgba.push(chunk[1]); // G
        rgba.push(chunk[0]); // B
        rgba.push(chunk[3]); // A
    }

    let encoder = Encoder::from_rgba(&rgba, width, height);
    let webp = encoder.encode(quality);
    Ok(webp.to_vec())
}

fn rgba_to_webp(
    rgba: &[u8],
    width: u32,
    height: u32,
    quality: f32, // 0.0 - 100.0
) -> Result<Vec<u8>, String> {
    let encoder = Encoder::from_rgba(rgba, width, height);
    let webp = encoder.encode(quality);
    Ok(webp.to_vec())
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
