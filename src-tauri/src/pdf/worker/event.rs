use std::path::PathBuf;

use flume::Sender;

use crate::pdf::{document::{DocumentId, PdfInfo}, reader::render::RenderedPage};

pub enum PdfEvent {
    Open {
        id: DocumentId,
        path: PathBuf,
    },
    Render {
        id: DocumentId,
        page_index: u16,
        target_width: i32,
        reply: Sender<RenderedPage>,
    },
    Info {
        id: DocumentId,
        reply: Sender<PdfInfo>
    },
    Close {
        id: DocumentId,
    },
}