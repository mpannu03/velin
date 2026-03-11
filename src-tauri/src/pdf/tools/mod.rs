pub mod merge;

pub use merge::*;
use serde::Deserialize;

use crate::utils::page_selection::PageSelection;

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
