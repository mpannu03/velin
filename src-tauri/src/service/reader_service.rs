use crate::{
    pdf::{
        document::PdfInfo,
        reader::{PageText, RenderedPage},
        worker::PdfEvent,
        Bookmarks,
    },
    state::AppState,
};
use flume::bounded;

pub fn open_pdf(state: &AppState, path: String) -> Result<String, String> {
    let id = state.manager.write().open(path.into())?;

    Ok(id)
}

pub fn render_page(
    state: &AppState,
    id: String,
    page_index: u16,
    target_width: i32,
) -> Result<RenderedPage, String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = flume::bounded(1);

    worker
        .sender()
        .send(PdfEvent::Render {
            id,
            page_index,
            target_width,
            reply: tx,
        })
        .map_err(|e| format!("Error sending render command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving render result: {e}"))?
}

pub fn get_pdf_info(state: &AppState, id: String) -> Result<PdfInfo, String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = flume::bounded(1);

    worker
        .sender()
        .send(PdfEvent::Info { id, reply: tx })
        .map_err(|e| format!("Error sending pdf info command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving pdf info result: {e}"))?
}

pub fn close_pdf(state: &AppState, id: String) -> Result<(), String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = bounded(1);

    worker
        .sender()
        .send(PdfEvent::Close { id, reply: tx })
        .map_err(|e| format!("Error sending close command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving close result: {e}"))?
}

pub fn get_bookmarks(state: &AppState, id: String) -> Result<Bookmarks, String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = bounded(1);

    worker
        .sender()
        .send(PdfEvent::Bookmarks { id, reply: tx })
        .map_err(|e| format!("Error sending bookmarks command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving bookmarks result: {e}"))?
}

pub fn get_text_by_page(state: &AppState, id: String, page_index: u16) -> Result<PageText, String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = bounded(1);

    worker
        .sender()
        .send(PdfEvent::Text {
            id,
            page_index,
            reply: tx,
        })
        .map_err(|e| format!("Error sending text command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving text result: {e}"))?
}
