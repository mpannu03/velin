use std::{collections::HashMap, thread};
use flume::{Receiver, Sender};
use pdfium_render::prelude::{PdfDocument, Pdfium};

use crate::pdf::{document::DocumentId, reader, worker::PdfEvent};

pub struct PdfWorker {
    sender: Sender<PdfEvent>
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
            PdfEvent::Render { id, page_index, target_width, reply } => {
                let result = reader::render_page(&documents, &id, page_index, target_width);
                let _ = reply.send(result);
            },
            PdfEvent::Info {id, reply} => {
                let result = reader::get_info(&documents, &id);
                let _ = reply.send(result);
            },
            PdfEvent::Close {id, reply} => {
                let result = reader::close(&mut documents, &id);
                let _ = reply.send(result);
            },
        }
    }
}