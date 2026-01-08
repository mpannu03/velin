use tauri::State;

use crate::{pdf::document::PdfInfo, service::reader_service, state::AppState};

#[tauri::command]
pub fn open_pdf(state: State<AppState>, path: String) -> Result<String, String> {
    reader_service::open_pdf(&state, path)
}

#[tauri::command]
pub async fn render_page(
    state: State<'_, AppState>,
    id: String,
    page_index: u16,
    target_width: i32,
) -> Result<tauri::ipc::Response, String> {
    let app_state = state.inner().clone();

    let page = tauri::async_runtime::spawn_blocking(move || {
        reader_service::render_page(&app_state, id, page_index, target_width)
    })
    .await
    .map_err(|e| e.to_string())??;

    // Pack data: [width: u32][height: u32][pixels...]
    // using u32 for width/height
    let mut data = Vec::with_capacity(8 + page.pixels.len());
    data.extend_from_slice(&(page.width as u32).to_be_bytes());
    data.extend_from_slice(&(page.height as u32).to_be_bytes());
    data.extend_from_slice(&page.pixels);

    Ok(tauri::ipc::Response::new(data))
}

#[tauri::command]
pub fn get_pdf_info(state: State<AppState>, id: String) -> Result<PdfInfo, String> {
    reader_service::get_pdf_info(&state, id)
}

#[tauri::command]
pub fn close_pdf(state: State<AppState>, id: String) -> Result<(), String> {
    reader_service::close_pdf(&state, id)
}
