use crate::pdf::tools::PageSelectionInput;
use pdfium_render::prelude::{Pdfium, PdfPageRenderRotation};
use std::path::PathBuf;

pub fn rotate(
    pdfium: &Pdfium,
    input: &PageSelectionInput,
    dest: &str,
    angle: i32,
) -> Result<(), String> {
    let path = PathBuf::from(&input.file);
    let pdf_document = pdfium
        .load_pdf_from_file(&path, None)
        .map_err(|e| e.to_string())?;

    let total_pages = pdf_document.pages().len() as u32;

    let target_pages = match &input.selection {
        Some(selection) => selection.resolve(total_pages).map_err(|e| e.to_string())?,
        None => (1..=total_pages).collect::<Vec<u32>>(),
    };

    for page_number in target_pages {
        let page_index = (page_number - 1) as u16;
        let mut page = pdf_document
            .pages()
            .get(page_index)
            .map_err(|e| e.to_string())?;

        let current_rotation = page.rotation().map_err(|e| e.to_string())?;
        let current_degrees = match current_rotation {
            PdfPageRenderRotation::None => 0,
            PdfPageRenderRotation::Degrees90 => 90,
            PdfPageRenderRotation::Degrees180 => 180,
            PdfPageRenderRotation::Degrees270 => 270,
        };

        let new_degrees = ((current_degrees + angle) % 360 + 360) % 360;

        let new_rotation = match new_degrees {
            0 => PdfPageRenderRotation::None,
            90 => PdfPageRenderRotation::Degrees90,
            180 => PdfPageRenderRotation::Degrees180,
            270 => PdfPageRenderRotation::Degrees270,
            _ => PdfPageRenderRotation::None,
        };

        page.set_rotation(new_rotation);
        let _ = page.regenerate_content();
    }

    pdf_document.save_to_file(&dest).map_err(|e| e.to_string())?;

    Ok(())
}
