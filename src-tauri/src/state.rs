//! Application state for Tauri commands.
//!
//! This module provides the `AppState` container used by Tauri command
//! handlers to access the shared `DocumentManager`. The manager is stored
//! behind an `Arc<RwLock<...>>` so it can be cloned and accessed concurrently
//! from multiple threads or command handlers.

use parking_lot::RwLock;
use std::sync::Arc;

use crate::pdf::manager::DocumentManager;

/// Application-wide state shared between Tauri commands and background tasks.
///
/// The `AppState` holds a shared `DocumentManager` wrapped in an `Arc` and
/// protected by a `RwLock` for concurrent reads/writes. Handlers can clone
/// the `Arc` or borrow the lock to access or modify documents.
#[derive(Clone)]
pub struct AppState {
    /// Shared `DocumentManager` instance protected by a `RwLock`.
    ///
    /// Use `.read()` to obtain a read guard for read-only access or `.write()`
    /// to obtain a mutable guard when modifying document data.
    pub manager: Arc<RwLock<DocumentManager>>,
}

impl AppState {
    /// Create a new `AppState` with a freshly-initialized `DocumentManager`.
    ///
    /// # Examples
    ///
    /// ```no_run
    /// let state = AppState::new();
    /// let mgr = state.manager.read();
    /// // use `mgr` to inspect documents
    /// ```
    pub fn new() -> Self {
        Self {
            manager: Arc::new(RwLock::new(DocumentManager::new())),
        }
    }
}
