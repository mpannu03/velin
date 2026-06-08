use lopdf::encryption::crypt_filters::{Aes128CryptFilter, CryptFilter};
use lopdf::{Document, EncryptionState, EncryptionVersion, Permissions};
use rand::Rng;
use serde::Deserialize;
use std::collections::BTreeMap;
use std::sync::Arc;

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProtectInput {
    pub input_path: String,
    pub output_path: String,
    pub password: String,
    pub require_password_to_open: bool,
    // Mapped 1-to-1 to lopdf Permissions bitflags
    pub allow_printing: bool,
    pub allow_high_quality_printing: bool,
    pub allow_modifying: bool,
    pub allow_copying: bool,
    pub allow_annotating: bool,
    pub allow_form_filling: bool,
    pub allow_assembly: bool,
}

pub fn protect_pdf(input: ProtectInput) -> Result<(), String> {
    let mut doc =
        Document::load(&input.input_path).map_err(|e| format!("Failed to load PDF: {e}"))?;

    if doc.is_encrypted() {
        return Err("Input PDF is already encrypted".into());
    }

    // COPYABLE_FOR_ACCESSIBILITY is deprecated since PDF 2.0 but must always be set for
    // backward compatibility with viewers following earlier specifications.
    let mut permissions = Permissions::COPYABLE_FOR_ACCESSIBILITY;

    if input.allow_printing {
        permissions |= Permissions::PRINTABLE;
    }
    if input.allow_high_quality_printing {
        permissions |= Permissions::PRINTABLE_IN_HIGH_QUALITY;
    }
    if input.allow_modifying {
        permissions |= Permissions::MODIFIABLE;
    }
    if input.allow_copying {
        permissions |= Permissions::COPYABLE;
    }
    if input.allow_annotating {
        permissions |= Permissions::ANNOTABLE;
    }
    if input.allow_form_filling {
        permissions |= Permissions::FILLABLE;
    }
    if input.allow_assembly {
        permissions |= Permissions::ASSEMBLABLE;
    }

    let crypt_filter: Arc<dyn CryptFilter> = Arc::new(Aes128CryptFilter);
    let mut file_encryption_key = [0u8; 32];
    rand::rng().fill(&mut file_encryption_key);

    let crypt_filters: BTreeMap<Vec<u8>, Arc<dyn CryptFilter>> =
        BTreeMap::from([(b"StdCF".to_vec(), crypt_filter)]);

    let user_password = if input.require_password_to_open {
        &input.password
    } else {
        ""
    };

    let encryption_version = EncryptionVersion::V4 {
        document: &doc,
        encrypt_metadata: true,
        crypt_filters,
        stream_filter: b"StdCF".to_vec(),
        string_filter: b"StdCF".to_vec(),
        owner_password: &input.password,
        user_password: user_password,
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
