use std::{path::PathBuf, thread};
use flume::{Receiver, Sender};
use pdfium_render::prelude::{PdfRenderConfig, Pdfium};

use crate::pdf::{document::PdfInfo, worker::PdfEvent};

pub struct PdfWorker {
    sender: Sender<PdfEvent>
}

impl PdfWorker {
    pub fn spawn(path: PathBuf) -> Self {
        let (tx, rx) = flume::unbounded::<PdfEvent>();

        thread::spawn(move || {
            worker_loop(path, rx);
        }); 

        Self { sender: tx }   
    }

    pub fn sender(&self) -> Sender<PdfEvent> {
        self.sender.clone()
    }
}

fn worker_loop(path: PathBuf, rx: Receiver<PdfEvent>) {
    let pdfium = Pdfium::default();

    let document = pdfium.load_pdf_from_file(&path, None)
        .expect("Failed to open Pdf");

    while let Ok(cmd) = rx.recv() {
        match cmd {
            PdfEvent::Render { page_index, scale, reply } => {
                let page = document.pages().get(page_index).unwrap();

                let config = PdfRenderConfig::new()
                    .set_target_width(page.width().value as i32);

                let bitmap = page.render_with_config(&config)
                    .expect("Rendering Error.");
                let bitmap = bitmap.as_raw_bytes();

                reply.send(bitmap).expect("Rendering Error.");
            },
            PdfEvent::Info {reply} => {
                let page_count = document.pages().len();
                let pdf_info = PdfInfo::new(page_count);

                reply.send(pdf_info).expect("Error loading info.");
            }
            PdfEvent::Close => break,
        }
    }
}