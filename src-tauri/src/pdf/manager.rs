use std::{
    path::PathBuf,
};

use uuid::Uuid;

use crate::pdf::{document::DocumentId, worker::{PdfEvent, PdfWorker}};

pub struct DocumentManager {
    worker: PdfWorker,
}

impl DocumentManager {
    pub fn new() -> Self {
        Self {
            worker: PdfWorker::spawn(),
        }
    }
    
    pub fn open(&mut self, path: PathBuf) -> Result<DocumentId, String> {
        let id = Uuid::new_v4().to_string();
        self.worker.sender().send(
            PdfEvent::Open { id: id.clone(), path }
        ).unwrap();
        Ok(id)
    }

    pub fn worker(&self) -> &PdfWorker {
        &self.worker
    }
}
