use crate::state::AppState;

mod state;
mod commands;
mod pdf;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_opener::init())
        .manage(AppState::new())
        .invoke_handler(tauri::generate_handler![
            // reader
            commands::reader::open_pdf,
            commands::reader::render_page,
            commands::reader::close_pdf,
            commands::reader::get_pdf_info,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
