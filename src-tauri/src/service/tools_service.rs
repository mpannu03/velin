use crate::{pdf::worker::PdfEvent, state::AppState};

pub async fn merge_pdfs(state: &AppState, files: Vec<String>, dest: String) -> Result<(), String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = flume::bounded(1);

    worker
        .sender()
        .send(PdfEvent::Merge {
            files,
            dest,
            reply: tx,
        })
        .map_err(|e| format!("Error sending merge command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving merge result: {e}"))?
}
