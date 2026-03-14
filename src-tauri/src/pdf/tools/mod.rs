pub mod extract;
pub mod merge;
pub mod split;

pub use extract::*;
pub use merge::*;
use serde::Deserialize;
pub use split::*;

use crate::utils::page_selection::{PageSelection, PageSelectionParser};

#[derive(Debug, Deserialize)]
pub struct PageSelectionInputRaw {
    pub file: String,
    pub selection: Option<String>,
}

#[derive(Debug)]
pub struct PageSelectionInput {
    pub file: String,
    pub selection: Option<PageSelection>,
}

pub fn prepare_page_selection_inputs(
    raw_inputs: Vec<PageSelectionInputRaw>,
) -> Result<Vec<PageSelectionInput>, String> {
    let mut inputs = Vec::new();

    for raw in raw_inputs {
        inputs.push(prepare_page_selection_input(raw)?);
    }

    Ok(inputs)
}

pub fn prepare_page_selection_input(
    raw: PageSelectionInputRaw,
) -> Result<PageSelectionInput, String> {
    let selection = match raw.selection {
        Some(expr) => {
            let parsed = PageSelectionParser::parse(&expr).map_err(|e| e.to_string())?;
            Some(parsed)
        }
        None => None,
    };

    Ok(PageSelectionInput {
        file: raw.file,
        selection,
    })
}
