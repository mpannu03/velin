// use pdfium_render::prelude::PdfRenderConfig;
// use pdfium_render::prelude::*;

// use crate::pdf::document::PdfDocument;

// /// Result of rendering a single PDF page.
// ///
// /// Pixel format: RGBA (8 bits per channel)
// pub struct RenderedPage {
//     pub width: i32,
//     pub height: i32,
//     pub pixels: Vec<u8>,
// }

// /// Renders a single page of a PDF into an RGBA bitmap.
// ///
// /// `page_index` is zero-based.
// /// `scale` controls DPI/zoom (1.0 = 100%).
// pub fn render_page(
//     document: &PdfDocument,
//     page_index: u16,
//     scale: f32,
// ) -> Result<RenderedPage, String> {
//     let inner = document.inner.read();

//     let pdfium_handle = inner
//         .pdfiumHandle
//         .as_ref()
//         .ok_or("PDF is not loaded")?;

//     // Access the actual pdfium_render document
//     let pdfium_doc = &pdfium_handle.doc;

//     // Get the requested page
//     let page = pdfium_doc
//         .pages()
//         .get(page_index)
//         .map_err(|_| "Invalid page index")?;

//     // Calculate scaled dimensions
//     let width = (page.width().value * scale) as i32;
//     let height = (page.height().value * scale) as i32;

//     // Render page to bitmap
//     let bitmap = page
//         .render_with_config(
//             &PdfRenderConfig::new()
//                 .set_target_width(width)
//                 .set_target_height(height)
//                 .render_form_data(true)
//                 .rotate_if_landscape(PdfPageRenderRotation::None, false),
//         )
//         .map_err(|e| format!("Render failed: {e}"))?;

//     // Get raw RGBA buffer
//     let buffer = bitmap
//         .as_raw_bytes();

//     Ok(RenderedPage {
//         width,
//         height,
//         pixels: buffer.to_vec(),
//     })
// }
