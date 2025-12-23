use std::sync::Arc;
use parking_lot::RwLock;

use crate::pdf::manager::DocumentManager;

/// Global application state shared across Tauri commands
#[derive(Clone)]
pub struct AppState {
    pub manager: Arc<RwLock<DocumentManager>>,
}

impl AppState {
    pub fn new() -> Self {
        Self {
            manager: Arc::new(RwLock::new(DocumentManager::new())),
        }
    }
}
