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

    let inputs = tools::prepare_page_selection_inputs(raw_inputs).map_err(|e| e.to_string())?;

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

pub async fn split_pdf(
    state: &AppState,
    raw_input: PageSelectionInputRaw,
    dest_dir: String,
    file_name: String,
) -> Result<(), String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = flume::bounded(1);

    let input = tools::prepare_page_selection_input(raw_input).map_err(|e| e.to_string())?;

    worker
        .sender()
        .send(PdfEvent::Split {
            input,
            dest_dir,
            file_name,
            reply: tx,
        })
        .map_err(|e| format!("Error sending split command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving split result: {e}"))?
}

pub async fn extract_pdf(
    state: &AppState,
    raw_input: PageSelectionInputRaw,
    dest: String,
) -> Result<(), String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = flume::bounded(1);

    let input = tools::prepare_page_selection_input(raw_input).map_err(|e| e.to_string())?;

    worker
        .sender()
        .send(PdfEvent::Extract {
            input,
            dest,
            reply: tx,
        })
        .map_err(|e| format!("Error sending extract command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving extract result: {e}"))?
}

pub async fn pdf_to_image(
    state: &AppState,
    raw_input: PageSelectionInputRaw,
    dest_dir: String,
    options: tools::PdfToImgOptions,
) -> Result<(), String> {
    let manager = state.manager.read();
    let worker = manager.worker();

    let (tx, rx) = flume::bounded(1);

    let input = tools::prepare_page_selection_input(raw_input).map_err(|e| e.to_string())?;

    worker
        .sender()
        .send(PdfEvent::PdfToImage {
            input,
            dest_dir,
            options,
            reply: tx,
        })
        .map_err(|e| format!("Error sending pdf to image command: {e}"))?;

    rx.recv()
        .map_err(|e| format!("Error receiving pdf to image result: {e}"))?
}
