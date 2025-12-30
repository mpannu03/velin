use tauri::State;

use crate::{pdf::{document::PdfInfo, reader::RenderedPage}, service::{reader_service}, state::AppState};

#[tauri::command]
pub fn open_pdf(
    state: State<AppState>, 
    path: String
) -> Result<String, String> {
    reader_service::open_pdf(&state, path)
}

#[tauri::command]
pub fn render_page(
    state: State<AppState>,
    id: String,
    page_index: u16,
    target_width: i32,
) -> Result<RenderedPage, String> {
    reader_service::render_page(&state, id, page_index, target_width)
}

#[tauri::command]
pub fn get_pdf_info(state: State<AppState>, id: String) -> Result<PdfInfo, String> {
    reader_service::get_pdf_info(&state, id)
}

#[tauri::command]
pub fn close_pdf(state: State<AppState>, id: String) -> Result<(), String> {
    reader_service::close_pdf(&state, id)
}