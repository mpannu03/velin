use flate2::read::GzDecoder;
use std::fs::File;
use std::path::Path;
use tar::Archive;

#[tauri::command]
pub async fn extract_tar_gz(path: String, dest: String) -> Result<(), String> {
    let tar_gz = File::open(path).map_err(|e| e.to_string())?;
    let tar = GzDecoder::new(tar_gz);
    let mut archive = Archive::new(tar);

    let dest_path = Path::new(&dest);
    archive.unpack(dest_path).map_err(|e| e.to_string())?;

    Ok(())
}
