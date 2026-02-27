use flume::{Receiver, Sender};
use pdfium_render::prelude::{PdfDocument, Pdfium};
use std::{collections::HashMap, thread};

use crate::pdf::{document::DocumentId, reader, worker::PdfEvent};

pub struct PdfWorker {
    sender: Sender<PdfEvent>,
}

impl PdfWorker {
    pub fn spawn() -> Self {
        let (tx, rx) = flume::unbounded::<PdfEvent>();

        for _ in 0..4 {
            let rx = rx.clone();
            thread::spawn(move || {
                worker_loop(rx);
            });
        }

        Self { sender: tx }
    }

    pub fn sender(&self) -> Sender<PdfEvent> {
        self.sender.clone()
    }
}

fn worker_loop(rx: Receiver<PdfEvent>) {
    let pdfium = Pdfium::default();
    let mut documents: HashMap<DocumentId, PdfDocument> = HashMap::new();
    let mut paths: HashMap<DocumentId, std::path::PathBuf> = HashMap::new();

    while let Ok(cmd) = rx.recv() {
        match cmd {
            PdfEvent::Open { id, path, reply } => {
                // Just store the path and verify it exists
                if path.exists() {
                    paths.insert(id, path);
                    let _ = reply.send(Ok(()));
                } else {
                    let _ = reply.send(Err("File not found".to_string()));
                }
            }
            PdfEvent::Render {
                id,
                page_index,
                target_width,
                reply,
            } => {
                let result = match ensure_doc(&pdfium, &mut documents, &paths, &id) {
                    Ok(_) => reader::render_page(&documents, &id, page_index, target_width),
                    Err(e) => Err(e),
                };
                let _ = reply.send(result);
            }
            PdfEvent::RenderTile {
                id,
                page_index,
                target_width,
                tile_x,
                tile_y,
                tile_width,
                tile_height,
                reply,
            } => {
                let result = match ensure_doc(&pdfium, &mut documents, &paths, &id) {
                    Ok(_) => reader::render_tile(
                        &documents,
                        &id,
                        page_index,
                        target_width,
                        tile_x,
                        tile_y,
                        tile_width,
                        tile_height,
                    ),
                    Err(e) => Err(e),
                };
                let _ = reply.send(result);
            }
            PdfEvent::Info { id, reply } => {
                let result = match ensure_doc(&pdfium, &mut documents, &paths, &id) {
                    Ok(_) => reader::get_info(&documents, &id),
                    Err(e) => Err(e),
                };
                let _ = reply.send(result);
            }
            PdfEvent::Close { id, reply } => {
                documents.remove(&id);
                paths.remove(&id);
                let _ = reply.send(Ok(()));
            }
            PdfEvent::Bookmarks { id, reply } => {
                let result = match ensure_doc(&pdfium, &mut documents, &paths, &id) {
                    Ok(_) => reader::get_bookmarks(&documents, &id),
                    Err(e) => Err(e),
                };
                let _ = reply.send(result);
            }
            PdfEvent::Text {
                id,
                page_index,
                reply,
            } => {
                let result = match ensure_doc(&pdfium, &mut documents, &paths, &id) {
                    Ok(_) => reader::get_text_by_page(&documents, &id, page_index),
                    Err(e) => Err(e),
                };
                let _ = reply.send(result);
            }
            PdfEvent::Search { id, query, reply } => {
                let result = match ensure_doc(&pdfium, &mut documents, &paths, &id) {
                    Ok(_) => reader::search_document(&documents, &id, &query),
                    Err(e) => Err(e),
                };
                let _ = reply.send(result);
            }
            PdfEvent::Preview {
                id,
                save_path,
                reply,
            } => {
                let result = match ensure_doc(&pdfium, &mut documents, &paths, &id) {
                    Ok(_) => reader::generate_preview(&documents, &id, save_path),
                    Err(e) => Err(e),
                };
                let _ = reply.send(result);
            }
            PdfEvent::GetAnnotations { id, reply } => {
                let result = match ensure_doc(&pdfium, &mut documents, &paths, &id) {
                    Ok(_) => reader::get_annotations(&documents, &id),
                    Err(e) => Err(e),
                };
                let _ = reply.send(result);
            }
            PdfEvent::AddAnnotation {
                id,
                annotation,
                reply,
            } => {
                let result = match ensure_doc(&pdfium, &mut documents, &paths, &id) {
                    Ok(_) => reader::add_annotation(&documents, &id, annotation),
                    Err(e) => Err(e),
                };
                let _ = reply.send(result);
            }
            PdfEvent::RemoveAnnotation {
                id,
                page_index,
                annotation_id,
                reply,
            } => {
                let result = match ensure_doc(&pdfium, &mut documents, &paths, &id) {
                    Ok(_) => reader::delete_annotation(&documents, &id, page_index, annotation_id),
                    Err(e) => Err(e),
                };
                let _ = reply.send(result);
            }
        }
    }
}

fn ensure_doc<'a>(
    pdfium: &'a Pdfium,
    documents: &mut HashMap<DocumentId, PdfDocument<'a>>,
    paths: &HashMap<DocumentId, std::path::PathBuf>,
    id: &DocumentId,
) -> Result<(), String> {
    if documents.contains_key(id) {
        return Ok(());
    }

    let path = paths
        .get(id)
        .ok_or_else(|| "Document path not found".to_string())?;

    reader::open(id.clone(), path, documents, pdfium)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    #[test]
    fn test_worker_spawn() {
        let _worker = PdfWorker::spawn();
    }

    #[test]
    fn test_worker_event_handling() {
        let worker = PdfWorker::spawn();
        let (tx, rx) = flume::bounded(1);

        // Test opening a non-existent file
        worker
            .sender()
            .send(PdfEvent::Open {
                id: "test".to_string(),
                path: PathBuf::from("non_existent.pdf"),
                reply: tx.clone(),
            })
            .unwrap();

        let result = rx.recv().unwrap();
        assert!(result.is_err());

        // Test closing a document that wasn't opened
        let (tx_close, rx_close) = flume::bounded(1);
        worker
            .sender()
            .send(PdfEvent::Close {
                id: "non_existent".to_string(),
                reply: tx_close,
            })
            .unwrap();

        let result_close = rx_close.recv().unwrap();
        assert!(result_close.is_err());
    }
}
