use std::path::PathBuf;

use pdfium_render::prelude::Pdfium;

pub fn merge(pdfium: &Pdfium, files: Vec<String>, dest: String) -> Result<(), String> {
    if files.is_empty() {
        return Err("No files provided".to_string());
    }

    let mut document = pdfium.create_new_pdf().map_err(|e| {
        println!("Error creating new PDF: {}", e);
        e.to_string()
    })?;

    for file in files {
        let path = PathBuf::from(file.clone());
        let pdf_document = pdfium
            .load_pdf_from_file(&path, None)
            .map_err(|e| e.to_string())?;

        document
            .pages_mut()
            .append(&pdf_document)
            .map_err(|e| e.to_string())?;
    }

    document.save_to_file(&dest).map_err(|e| e.to_string())?;

    Ok(())
}
