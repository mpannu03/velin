use std::path::PathBuf;

use flume::Sender;

use crate::pdf::{
    document::{Bookmarks, DocumentId, PdfInfo},
    reader::{PageText, RenderedPage},
};

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
    Bookmarks {
        id: DocumentId,
        reply: Sender<Result<Bookmarks, String>>,
    },
    Text {
        id: DocumentId,
        page_index: u16,
        reply: Sender<Result<PageText, String>>,
    },
}
