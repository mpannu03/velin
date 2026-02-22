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

        thread::spawn(move || {
            worker_loop(rx);
        });

        Self { sender: tx }
    }

    pub fn sender(&self) -> Sender<PdfEvent> {
        self.sender.clone()
    }
}

fn worker_loop(rx: Receiver<PdfEvent>) {
    let pdfium = Pdfium::default();

    let mut documents: HashMap<DocumentId, PdfDocument> = HashMap::new();

    while let Ok(cmd) = rx.recv() {
        match cmd {
            PdfEvent::Open { id, path, reply } => {
                let result = reader::open(id, &path, &mut documents, &pdfium);
                let _ = reply.send(result);
            }
            PdfEvent::Render {
                id,
                page_index,
                target_width,
                reply,
            } => {
                let result = reader::render_page(&documents, &id, page_index, target_width);
                let _ = reply.send(result);
            }
            PdfEvent::Info { id, reply } => {
                let result = reader::get_info(&documents, &id);
                let _ = reply.send(result);
            }
            PdfEvent::Close { id, reply } => {
                let result = reader::close(&mut documents, &id);
                let _ = reply.send(result);
            }
            PdfEvent::Bookmarks { id, reply } => {
                let result = reader::get_bookmarks(&documents, &id);
                let _ = reply.send(result);
            }
            PdfEvent::Text {
                id,
                page_index,
                reply,
            } => {
                let result = reader::get_text_by_page(&documents, &id, page_index);
                let _ = reply.send(result);
            }
            PdfEvent::Search { id, query, reply } => {
                let result = reader::search_document(&documents, &id, &query);
                let _ = reply.send(result);
            }
            PdfEvent::Preview {
                id,
                save_path,
                reply,
            } => {
                let result = reader::generate_preview(&documents, &id, save_path);
                let _ = reply.send(result);
            }
            PdfEvent::GetAnnotations { id, reply } => {
                let result = reader::get_annotations(&documents, &id);
                let _ = reply.send(result);
            }
            PdfEvent::AddAnnotation {
                id,
                annotation,
                reply,
            } => {
                let result = reader::add_annotation(&documents, &id, annotation);
                let _ = reply.send(result);
            }
            PdfEvent::RemoveAnnotation {
                id,
                page_index,
                annotation_id,
                reply,
            } => {
                let result = reader::delete_annotation(&documents, &id, page_index, annotation_id);
                let _ = reply.send(result);
            }
        }
    }
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
