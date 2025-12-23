use flume::Sender;

use crate::pdf::document::PdfInfo;

pub enum PdfEvent {
    Render {
        page_index: u16,
        scale: f32,
        reply: Sender<Vec<u8>>,
    },
    Info {
        reply: Sender<PdfInfo>
    },
    Close,
}