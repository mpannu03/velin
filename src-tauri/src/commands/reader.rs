use flume::bounded;
use tauri::State;

use crate::{pdf::{document::PdfInfo, reader::render::RenderedPage, worker::PdfEvent}, state::AppState};

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
    target_width: i32,
) -> RenderedPage {
    let manager = state
        .manager
        .read();
    let worker = manager.worker();

    let (tx, rx) = bounded(1);

    worker.sender().send(
        PdfEvent::Render {
            id,
            page_index,
            target_width,
            reply: tx,
        }
    ).unwrap();

    rx.recv().unwrap()
}

#[tauri::command]
pub fn get_pdf_info(state: State<AppState>, id: String) -> PdfInfo {
    let manager = state
        .manager
        .read();
    let worker = manager.worker();

    let (tx, rx) = bounded(1);

    worker.sender().send(
        PdfEvent::Info { id, reply: tx }
    ).unwrap();

    rx.recv().unwrap()
}

#[tauri::command]
pub fn close_pdf(state: State<AppState>, id: String) {
    let manager = state
        .manager
        .read();
    let worker = manager.worker();

    worker.sender().send(
        PdfEvent::Close { id }
    ).unwrap();
}