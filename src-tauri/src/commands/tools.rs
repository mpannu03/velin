use flate2::read::GzDecoder;
use std::fs::File;
use std::path::Path;
use tar::Archive;

use crate::pdf::tools::PageSelectionInputRaw;
use crate::service::tools_service;
use crate::state::AppState;
use tauri::State;

#[tauri::command]
pub async fn extract_tar_gz(path: String, dest: String) -> Result<(), String> {
    let tar_gz = File::open(path).map_err(|e| e.to_string())?;
    let tar = GzDecoder::new(tar_gz);
    let mut archive = Archive::new(tar);

    let dest_path = Path::new(&dest);
    archive.unpack(dest_path).map_err(|e| e.to_string())?;

    Ok(())
}

#[tauri::command]
pub async fn merge_pdfs(
    state: State<'_, AppState>,
    raw_inputs: Vec<PageSelectionInputRaw>,
    dest: String,
) -> Result<(), String> {
    tools_service::merge_pdfs(&state, raw_inputs, dest).await
}

#[tauri::command]
pub async fn split_pdf(
    state: State<'_, AppState>,
    raw_input: PageSelectionInputRaw,
    dest_dir: String,
    file_name: String,
) -> Result<(), String> {
    tools_service::split_pdf(&state, raw_input, dest_dir, file_name).await
}
