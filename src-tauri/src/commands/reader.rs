use flume::bounded;
use tauri::State;

use crate::{pdf::{document::PdfInfo, worker::PdfEvent}, state::AppState};

#[tauri::command]
pub fn open_pdf(state: State<AppState>, path: String) -> String {
    let id = state
        .manager
        .write()
        .open(path.into())
        .expect("Error Opening");

    id
}

#[tauri::command]
pub fn render_page(
    state: State<AppState>,
    id: String,
    page_index: u16,
    scale: f32,
) -> Vec<u8> {
    let binding = state
        .manager
        .read();
    let worker = binding
        .get(id)
        .expect("Document not found");

    let (tx, rx) = bounded(1);

    worker.sender().send(
        PdfEvent::Render {
            page_index,
            scale,
            reply: tx,
        }
    ).unwrap();

    rx.recv().unwrap()
}

#[tauri::command]
pub fn get_pdf_info(state: State<AppState>, id: String) -> PdfInfo {
    let binding = state
        .manager
        .read();
    let worker = binding
        .get(id)
        .expect("Document not found");

    let (tx, rx) = bounded(1);

    worker.sender().send(
        PdfEvent::Info { reply: tx }
    ).unwrap();

    rx.recv().unwrap()
}

#[tauri::command]
pub fn close_pdf(state: State<AppState>, id: String) {
    state.manager.write().close(id);
}