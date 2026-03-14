use std::path::PathBuf;

use crate::pdf::tools::PageSelectionInput;
use pdfium_render::prelude::Pdfium;

pub fn split(
    pdfium: &Pdfium,
    input: &PageSelectionInput,
    dest_dir: &str,
    file_name: &str,
) -> Result<(), String> {
    let path = PathBuf::from(&input.file);
    let pdf_document = pdfium
        .load_pdf_from_file(&path, None)
        .map_err(|e| e.to_string())?;
    let total_pages = pdf_document.pages().len() as u32;

    match &input.selection {
        Some(selection) => {
            let selection_groups = selection
                .resolve_groups(total_pages)
                .map_err(|e| e.to_string())?;

            for (index, selection) in selection_groups.iter().enumerate() {
                let mut document = pdfium.create_new_pdf().map_err(|e| e.to_string())?;

                for page_number in selection {
                    let page_index = (page_number - 1) as u16;
                    let page_length = document.pages().len() as u16;

                    document
                        .pages_mut()
                        .copy_page_from_document(&pdf_document, page_index, page_length)
                        .map_err(|e| e.to_string())?;
                }

                let dest_path =
                    PathBuf::from(dest_dir).join(format!("{}_{}.pdf", file_name, index + 1));
                document
                    .save_to_file(&dest_path)
                    .map_err(|e| e.to_string())?;
            }
        }
        None => {
            let mut document = pdfium.create_new_pdf().map_err(|e| e.to_string())?;

            document
                .pages_mut()
                .append(&pdf_document)
                .map_err(|e| e.to_string())?;

            let dest_path = PathBuf::from(dest_dir).join(format!("{}.pdf", file_name));
            document
                .save_to_file(&dest_path)
                .map_err(|e| e.to_string())?;
        }
    }

    Ok(())
}
