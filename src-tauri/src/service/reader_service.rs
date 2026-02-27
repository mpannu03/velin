use std::path::PathBuf;

use crate::{
    pdf::{
        document::PdfInfo,
        reader::{Annotation, PageText, RenderedPage, RenderedTile, SearchHit},
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

pub fn render_tile(
    state: &AppState,
    id: String,
    page_index: u16,
    target_width: i32,
    tile_x: i32,
    tile_y: i32,
    tile_width: i32,
    tile_height: i32,
) -> Result<RenderedTile, String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = bounded(1);

    worker
        .sender()
        .send(PdfEvent::RenderTile {
            id,
            page_index,
            target_width,
            tile_x,
            tile_y,
            tile_width,
            tile_height,
            reply: tx,
        })
        .map_err(|e| format!("Error sending render tile command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving render tile result: {e}"))?
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

pub fn search_document(
    state: &AppState,
    id: String,
    query: String,
) -> Result<Vec<SearchHit>, String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = bounded(1);

    worker
        .sender()
        .send(PdfEvent::Search {
            id,
            query,
            reply: tx,
        })
        .map_err(|e| format!("Error sending search command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving search result: {e}"))?
}

pub fn generate_preview(
    state: &AppState,
    id: String,
    save_path: Option<PathBuf>,
) -> Result<Vec<u8>, String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = bounded(1);

    worker
        .sender()
        .send(PdfEvent::Preview {
            id,
            save_path,
            reply: tx,
        })
        .map_err(|e| format!("Error sending preview command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving preview result: {e}"))?
}

pub fn get_annotations(state: &AppState, id: String) -> Result<Vec<Annotation>, String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = bounded(1);

    worker
        .sender()
        .send(PdfEvent::GetAnnotations { id, reply: tx })
        .map_err(|e| format!("Error sending get annotations command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving get annotations result: {e}"))?
}

pub fn add_annotation(state: &AppState, id: String, annotation: Annotation) -> Result<(), String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = bounded(1);

    worker
        .sender()
        .send(PdfEvent::AddAnnotation {
            id,
            annotation,
            reply: tx,
        })
        .map_err(|e| format!("Error sending add annotation command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving add annotation result: {e}"))?
}

pub fn remove_annotation(
    state: &AppState,
    id: String,
    page_index: u16,
    annotation_id: String,
) -> Result<(), String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = bounded(1);

    worker
        .sender()
        .send(PdfEvent::RemoveAnnotation {
            id,
            page_index,
            annotation_id,
            reply: tx,
        })
        .map_err(|e| format!("Error sending remove annotation command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving remove annotation result: {e}"))?
}
