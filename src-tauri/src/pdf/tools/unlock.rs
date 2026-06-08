use lopdf::Document;
use serde::Deserialize;

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UnlockInput {
    pub input_path: String,
    pub output_path: String,
    pub password: String,
}

pub fn unlock_pdf(input: UnlockInput) -> Result<(), String> {
    let mut doc = Document::load_with_password(&input.input_path, &input.password)
        .map_err(|e| format!("Failed to load PDF: {e}"))?;

    if doc.is_encrypted() {
        return Err("Failed to remove encryption from the PDF. The file may be corrupted.".into());
    }

    doc.save(&input.output_path)
        .map_err(|e| format!("Failed to save PDF: {e}"))?;

    Ok(())
}
