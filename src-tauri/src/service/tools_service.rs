use crate::{
    pdf::{
        tools::{self, PageSelectionInputRaw},
        worker::PdfEvent,
    },
    state::AppState,
};

pub async fn merge_pdfs(
    state: &AppState,
    raw_inputs: Vec<PageSelectionInputRaw>,
    dest: String,
) -> Result<(), String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = flume::bounded(1);

    let inputs = tools::prepare_merge_inputs(raw_inputs).map_err(|e| e.to_string())?;

    worker
        .sender()
        .send(PdfEvent::Merge {
            inputs,
            dest,
            reply: tx,
        })
        .map_err(|e| format!("Error sending merge command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving merge result: {e}"))?
}
