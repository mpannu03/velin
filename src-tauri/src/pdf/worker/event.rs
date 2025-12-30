use std::path::PathBuf;

use flume::Sender;

use crate::pdf::{document::{DocumentId, PdfInfo}, reader::RenderedPage};

pub enum PdfEvent {
    Open {
        id: DocumentId,
        path: PathBuf,
        reply: Sender<Result<(), String>>,
    },
    Render {
        id: DocumentId,
        page_index: u16,
        target_width: i32,
        reply: Sender<Result<RenderedPage, String>>,
    },
    Info {
        id: DocumentId,
        reply: Sender<Result<PdfInfo, String>>,
    },
    Close {
        id: DocumentId,
        reply: Sender<Result<(), String>>,
    },
}