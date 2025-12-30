use crate::state::AppState;

mod state;
mod commands;
mod pdf;
mod service;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    #[cfg(debug_assertions)] // only enable instrumentation in development builds
    let devtools = tauri_plugin_devtools::init();

    let mut builder = tauri::Builder::default();

    #[cfg(debug_assertions)]
    {
        builder = builder.plugin(devtools);
    }

    builder
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
