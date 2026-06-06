use lopdf::{Document, EncryptionState, EncryptionVersion, Permissions};
use serde::Deserialize;

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProtectInput {
    pub input_path: String,
    pub output_path: String,
    pub password: String,
    pub allow_printing: bool,
    pub allow_assembly: bool,
    pub allow_commenting: bool,
    pub allow_copying: bool,
}

pub fn protect_pdf(input: ProtectInput) -> Result<(), String> {
    let mut doc =
        Document::load(&input.input_path).map_err(|e| format!("Failed to load PDF: {e}"))?;

    // TODO: Replace with actual permission flags available in your version.
    let permissions = Permissions::all();

    let encryption_version = EncryptionVersion::V2 {
        document: &doc,
        owner_password: &input.password,
        user_password: &input.password,
        key_length: 128,
        permissions,
    };

    let encryption_state = EncryptionState::try_from(encryption_version)
        .map_err(|e| format!("Failed to create encryption state: {e}"))?;

    doc.encrypt(&encryption_state)
        .map_err(|e| format!("Encryption failed: {e}"))?;

    doc.save(&input.output_path)
        .map_err(|e| format!("Failed to save PDF: {e}"))?;

    Ok(())
}
