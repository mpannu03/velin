use tauri::{AppHandle, Manager, State};

use crate::{
    pdf::{
        document::PdfInfo,
        reader::{Annotation, PageText, SearchHit},
        Bookmarks,
    },
    service::reader_service,
    state::AppState,
};

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

#[tauri::command]
pub fn get_bookmarks(state: State<AppState>, id: String) -> Result<Bookmarks, String> {
    reader_service::get_bookmarks(&state, id)
}

#[tauri::command]
pub fn get_text_by_page(
    state: State<AppState>,
    id: String,
    page_index: u16,
) -> Result<PageText, String> {
    reader_service::get_text_by_page(&state, id, page_index)
}

#[tauri::command]
pub fn search_document(
    state: State<AppState>,
    id: String,
    query: String,
) -> Result<Vec<SearchHit>, String> {
    reader_service::search_document(&state, id, query)
}

#[tauri::command]
pub fn generate_preview(
    app: AppHandle,
    state: State<AppState>,
    id: String,
) -> Result<Vec<u8>, String> {
    let app_data = app
        .path()
        .app_cache_dir()
        .map_err(|e| format!("Failed to get app cache dir: {e}"))?;
    let previews_dir = app_data.join("previews");
    let save_path = previews_dir.join(format!("{}.webp", id));

    reader_service::generate_preview(&state, id, Some(save_path))
}

#[tauri::command]
pub fn get_annotations(state: State<AppState>, id: String) -> Result<Vec<Annotation>, String> {
    reader_service::get_annotations(&state, id)
}

#[tauri::command]
pub fn add_annotation(
    state: State<AppState>,
    id: String,
    annotation: Annotation,
) -> Result<(), String> {
    reader_service::add_annotation(&state, id, annotation)
}

#[tauri::command]
pub fn remove_annotation(
    state: State<AppState>,
    id: String,
    page_index: u16,
    annotation_id: String,
) -> Result<(), String> {
    reader_service::remove_annotation(&state, id, page_index, annotation_id)
}
