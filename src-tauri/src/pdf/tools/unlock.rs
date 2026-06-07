use lopdf::{Document, EncryptionState};
use serde::Deserialize;

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UnlockInput {
    pub input_path: String,
    pub output_path: String,
    pub password: String,
}

pub fn unlock_pdf(input: UnlockInput) -> Result<(), String> {
    let mut doc =
        Document::load(&input.input_path).map_err(|e| format!("Failed to load PDF: {e}"))?;

    if doc.is_encrypted() {
        doc.decrypt(&input.password)
            .map_err(|e| format!("Failed to decrypt PDF: {e}"))?;
    }

    doc.save(&input.output_path)
        .map_err(|e| format!("Failed to save PDF: {e}"))?;

    Ok(())
}
