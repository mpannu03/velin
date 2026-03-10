use std::path::PathBuf;

use pdfium_render::prelude::Pdfium;
use serde::Deserialize;

use crate::utils::page_selection::{PageSelection, PageSelectionParser};

#[derive(Debug, Deserialize)]
pub struct MergeInputRaw {
    pub file: String,
    pub selection: Option<String>,
}

#[derive(Debug)]
pub struct MergeInput {
    pub file: String,
    pub selection: Option<PageSelection>,
}

pub fn merge(pdfium: &Pdfium, inputs: Vec<MergeInput>, dest: String) -> Result<(), String> {
    if inputs.is_empty() {
        return Err("No files provided".to_string());
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

pub fn prepare_merge_inputs(raw_inputs: Vec<MergeInputRaw>) -> Result<Vec<MergeInput>, String> {
    let mut inputs = Vec::new();

    for raw in raw_inputs {
        let selection = match raw.selection {
            Some(expr) => {
                let parsed = PageSelectionParser::parse(&expr).map_err(|e| e.to_string())?;
                Some(parsed)
            }

            None => None,
        };

        inputs.push(MergeInput {
            file: raw.file,
            selection,
        });
    }

    Ok(inputs)
}
