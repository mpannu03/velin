use flume::bounded;
use tauri::State;

use crate::{pdf::worker::PdfEvent, state::AppState};

pub fn open_pdf(
    state: &State<AppState>, path: String
) -> Result<String, String> {
    let id = state
        .manager
        .write()
        .open(path.into())?;

    Ok(id)
}

pub fn render_page(
    state: &State<AppState>,
    id: String,
    page_index: u16,
    target_width: i32,
) -> Result<crate::pdf::reader::RenderedPage, String> {
    let manager = state
        .manager
        .read();
    let worker = manager.worker();

    let (tx, rx) = flume::bounded(1);

    worker.sender().send(
        PdfEvent::Render {
            id,
            page_index,
            target_width,
            reply: tx,
        }
    ).map_err(|e| format!("Error sending render command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving render result: {e}"))?
}

pub fn get_pdf_info(
    state: &State<AppState>, 
    id: String
) -> Result<crate::pdf::document::PdfInfo, String> {
    let manager = state
        .manager
        .read();
    let worker = manager.worker();

    let (tx, rx) = flume::bounded(1);

    worker.sender().send(
        PdfEvent::Info { id, reply: tx }
    ).map_err(|e| format!("Error sending pdf info command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving pdf info result: {e}"))?
}

pub fn close_pdf(
    state: &State<AppState>, 
    id: String
) -> Result<(), String> {
    let manager = state
        .manager
        .read();
    let worker = manager.worker();

    let (tx, rx) = bounded(1);

    worker.sender().send(
        PdfEvent::Close { id, reply: tx }
    ).map_err(|e| format!("Error sending close command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving close result: {e}"))?
}