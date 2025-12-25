use std::{collections::HashMap, thread};
use flume::{Receiver, Sender};
use pdfium_render::prelude::{PdfDocument, PdfRenderConfig, Pdfium};

use crate::pdf::{document::{DocumentId, PdfInfo}, reader::render::RenderedPage, worker::PdfEvent};

type RenderKey = (DocumentId, u16, u32);

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
            PdfEvent::Open { id, path } => {
                let doc = pdfium
                    .load_pdf_from_file(&path, None)
                    .expect("Failed to open PDF");
                documents.insert(id, doc);
            }
            PdfEvent::Render { id, page_index, scale, reply } => {
                println!("rendering {}", {&id});
                let document = documents.get(&id).unwrap();
                let page = document.pages().get(page_index).unwrap();

                let target_width = (page.width().value * scale) as i32;
                let target_height = (page.height().value * scale) as i32;

                let config = PdfRenderConfig::new()
                    .set_target_width(target_width)
                    .set_target_height(target_height);

                let bitmap = page.render_with_config(&config)
                    .expect("Rendering Error.");
                // let bitmap = bitmap.as_raw_bytes();

                let rendered_page = RenderedPage{
                    width: bitmap.width(),
                    height: bitmap.height(),
                    pixels: bitmap.as_raw_bytes(),
                };

                reply.send(rendered_page).expect("Rendering Error.");
                println!("sent {}", {id});
            },
            PdfEvent::Info {id, reply} => {
                let document = documents.get(&id).unwrap();
                let page_count = document.pages().len();
                let pdf_info = PdfInfo::new(page_count);

                reply.send(pdf_info).expect("Error loading info.");
            }
            PdfEvent::Close {id} => {
                documents.remove(&id);
            },
        }
    }
}