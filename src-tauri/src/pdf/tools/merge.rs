use std::path::PathBuf;

use pdfium_render::prelude::Pdfium;

use crate::pdf::tools::PageSelectionInput;

pub fn merge(pdfium: &Pdfium, inputs: Vec<PageSelectionInput>, dest: String) -> Result<(), String> {
    if inputs.is_empty() {
        return Err("No inputs provided".to_string());
    }

    let mut document = pdfium.create_new_pdf().map_err(|e| e.to_string())?;

    for input in inputs {
        let path = PathBuf::from(&input.file);

        let pdf_document = pdfium
            .load_pdf_from_file(&path, None)
            .map_err(|e| e.to_string())?;

        match input.selection {
            Some(selection) => {
                let total_pages = pdf_document.pages().len() as u32;

                let pages = selection.resolve(total_pages).map_err(|e| e.to_string())?;

                for page_number in pages {
                    let page_index = (page_number - 1) as u16;
                    let page_length = document.pages().len() as u16;

                    document
                        .pages_mut()
                        .copy_page_from_document(&pdf_document, page_index, page_length)
                        .map_err(|e| e.to_string())?;
                }
            }

            None => {
                document
                    .pages_mut()
                    .append(&pdf_document)
                    .map_err(|e| e.to_string())?;
            }
        }
    }

    document.save_to_file(&dest).map_err(|e| e.to_string())?;

    Ok(())
}
