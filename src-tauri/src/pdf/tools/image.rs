use image::ImageEncoder;
use pdfium_render::prelude::Pdfium;
use serde::{Deserialize, Serialize};
use std::{fs::File, io::Write, path::PathBuf};

use crate::pdf::tools::PageSelectionInput;

#[derive(Debug, Serialize, Deserialize, Clone, Copy, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum ImageType {
    PNG,
    JPEG,
    WEBP,
}

#[derive(Debug, Serialize, Deserialize, Clone, Copy, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum ImageMode {
    COLOR,
    GRAYSCALE,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct PdfToImgOptions {
    pub format: ImageType,
    pub dpi: u32,
    pub quality: u8,
    pub mode: ImageMode,
    pub pattern: String,
}

pub fn pdf_to_image(
    pdfium: &Pdfium,
    input: &PageSelectionInput,
    dest_dir: &str,
    options: &PdfToImgOptions,
) -> Result<(), String> {
    let path = PathBuf::from(&input.file);
    let pdf_document = pdfium
        .load_pdf_from_file(&path, None)
        .map_err(|e| e.to_string())?;

    let total_pages = pdf_document.pages().len() as u32;

    let pages_to_convert = match &input.selection {
        Some(selection) => selection.resolve(total_pages).map_err(|e| e.to_string())?,
        None => (1..=total_pages).collect::<Vec<u32>>(),
    };

    for page_number in pages_to_convert {
        let page_index = (page_number - 1) as u16;
        let page = pdf_document
            .pages()
            .get(page_index)
            .map_err(|e| e.to_string())?;

        let render_config = pdfium_render::prelude::PdfRenderConfig::new()
            .set_target_width((page.width().value as f32 * (options.dpi as f32 / 72.0)) as i32)
            .set_maximum_height((page.height().value as f32 * (options.dpi as f32 / 72.0)) as i32);

        let render_config = if options.mode == ImageMode::GRAYSCALE {
            render_config.use_grayscale_rendering(true)
        } else {
            render_config
        };

        let bitmap = page
            .render_with_config(&render_config)
            .map_err(|e| e.to_string())?;

        let width = bitmap.width() as u32;
        let height = bitmap.height() as u32;
        let raw_data = bitmap.as_raw_bytes();

        let filename = options.pattern.replace("{n}", &page_number.to_string());
        let dest_path = PathBuf::from(dest_dir).join(filename);
        let dest_str = dest_path.to_str().ok_or("Invalid destination path")?;

        raw_to_image(
            raw_data,
            width,
            height,
            options.format,
            options.quality,
            dest_str,
        )?;
    }

    Ok(())
}

fn raw_to_image(
    raw: Vec<u8>,
    width: u32,
    height: u32,
    format: ImageType,
    quality: u8,
    dest: &str,
) -> Result<(), String> {
    let image = image::RgbaImage::from_raw(width, height, raw).ok_or("Failed to create image")?;

    match format {
        ImageType::PNG => {
            let mut file = File::create(format!("{}.png", dest)).map_err(|e| e.to_string())?;

            let compression = if quality == 100 {
                image::codecs::png::CompressionType::Uncompressed
            } else {
                image::codecs::png::CompressionType::Level((10 - quality / 10) as u8)
            };

            let encoder = image::codecs::png::PngEncoder::new_with_quality(
                &mut file,
                compression,
                image::codecs::png::FilterType::Adaptive,
            );
            encoder
                .write_image(&image, width, height, image::ExtendedColorType::Rgba8)
                .map_err(|e| e.to_string())?;
        }
        ImageType::JPEG => {
            let mut file = File::create(format!("{}.jpeg", dest)).map_err(|e| e.to_string())?;

            let rgb_image: Vec<u8> = image
                .chunks(4)
                .flat_map(|pixel| &pixel[0..3])
                .copied()
                .collect();

            let encoder = image::codecs::jpeg::JpegEncoder::new_with_quality(&mut file, quality);
            encoder
                .write_image(&rgb_image, width, height, image::ExtendedColorType::Rgb8)
                .map_err(|e| e.to_string())?;
        }
        ImageType::WEBP => {
            let mut file = File::create(format!("{}.webp", dest)).map_err(|e| e.to_string())?;
            let encoder = webp::Encoder::from_rgba(&image, width, height);
            let webp = encoder.encode(quality as f32);
            file.write(&webp).map_err(|e| e.to_string())?;
        }
    }
    Ok(())
}
