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

        let (tx, rx) = flume::bounded(1);

        self.worker.sender().send(
            PdfEvent::Open { id: id.clone(), path, reply: tx }
        ).map_err(|e| format!("Error sending open command: {e}"))?;

        let _ = rx.recv()
            .map_err(|e| format!("Error receiving open result: {e}"))?;

        Ok(id)
    }

    pub fn worker(&self) -> &PdfWorker {
        &self.worker
    }
}
