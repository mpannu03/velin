use std::{
    collections::HashMap,
    path::PathBuf,
};

use flume::bounded;
use uuid::Uuid;

use crate::pdf::{document::DocumentId, worker::{PdfEvent, PdfWorker}};

pub struct DocumentManager {
    documents: HashMap<DocumentId, PdfWorker>
}

impl DocumentManager {
    pub fn new() -> Self {
        Self { documents: HashMap::new() }
    }
    
    pub fn open(&mut self, path: PathBuf) -> Result<DocumentId, String> {
        let id = Uuid::new_v4().to_string();
        let worker = PdfWorker::spawn(path);

        self.documents.insert(id.clone(), worker);
        Ok(id)
    }

    pub fn get(&self, id: DocumentId) -> Option<&PdfWorker> {
        self.documents.get(&id)
    }

    pub fn close(&mut self, id: DocumentId) {
        if let Some(worker) = self.documents.remove(&id) {
            worker.sender().send(PdfEvent::Close).ok();
        }
    }
}
