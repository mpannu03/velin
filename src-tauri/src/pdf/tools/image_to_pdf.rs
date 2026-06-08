use std::io::Write;
use std::path::PathBuf;

use image::GenericImageView;
use lopdf::{dictionary, Document, Object, ObjectId, Stream};
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone, Copy, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum PageSize {
    Auto,
    A4,
    Letter,
}

#[derive(Debug, Serialize, Deserialize, Clone, Copy, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum Orientation {
    Auto,
    Portrait,
    Landscape,
}

#[derive(Debug, Serialize, Deserialize, Clone, Copy, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum ImageFit {
    Contain,
    Cover,
    Stretch,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ImageToPdfOptions {
    pub page_size: PageSize,
    pub orientation: Orientation,
    pub fit: ImageFit,
    pub margin: f32,
}

impl Default for ImageToPdfOptions {
    fn default() -> Self {
        Self {
            page_size: PageSize::Auto,
            orientation: Orientation::Auto,
            fit: ImageFit::Contain,
            margin: 20.0,
        }
    }
}

pub fn image_to_pdf(
    image_paths: &[String],
    dest: &str,
    options: &ImageToPdfOptions,
) -> Result<(), String> {
    if image_paths.is_empty() {
        return Err("No image files provided".to_string());
    }

    let mut doc = Document::new();
    let mut page_ids = Vec::new();
    let mut pages_info: Vec<(f32, f32, ObjectId, ObjectId)> = Vec::new();

    // First pass: create all page content, image objects but NOT page objects yet
    for image_path_str in image_paths {
        let path = PathBuf::from(image_path_str);
        let img = image::open(&path).map_err(|e| format!("Failed to open image: {e}"))?;

        let (img_w, img_h) = img.dimensions();
        let (page_w, page_h) = calculate_page_dimensions(
            img_w as f32,
            img_h as f32,
            options.page_size,
            options.orientation,
            options.margin,
        );

        let rgb_img = img.to_rgb8();
        let raw_data = rgb_img.as_raw().to_vec();

        // Compress with flate2
        use flate2::write::ZlibEncoder;
        use flate2::Compression;
        let mut encoder = ZlibEncoder::new(Vec::new(), Compression::default());
        encoder
            .write_all(&raw_data)
            .map_err(|e| format!("Compression error: {e}"))?;
        let compressed = encoder
            .finish()
            .map_err(|e| format!("Compression error: {e}"))?;

        // Create image XObject stream
        let image_stream = Stream::new(
            dictionary! {
                "Type" => "XObject",
                "Subtype" => "Image",
                "Width" => img_w as i64,
                "Height" => img_h as i64,
                "ColorSpace" => "DeviceRGB",
                "BitsPerComponent" => 8,
                "Filter" => "FlateDecode",
                "Length" => compressed.len() as i64,
            },
            compressed,
        );

        let image_id = doc.add_object(image_stream);

        // Calculate the image placement on the page
        let (x, y, draw_w, draw_h) = calculate_image_placement(
            img_w as f32,
            img_h as f32,
            page_w,
            page_h,
            options.margin,
            options.fit,
        );

        // Create content stream for the page
        let content = format!(
            "q\n{:.2} 0 0 {:.2} {:.2} {:.2} cm\n/Im{} Do\nQ\n",
            draw_w, draw_h, x, y, image_id.0
        );
        let content_bytes = content.into_bytes();

        let content_stream = Stream::new(
            dictionary! {
                "Length" => content_bytes.len() as i64,
            },
            content_bytes,
        );

        let content_id = doc.add_object(content_stream);
        pages_info.push((page_w, page_h, image_id, content_id));
    }

    doc.version = "1.7".to_string();

    // Create page objects with Parent reference (we know pages_id will be the next one)
    // We create pages first, then pages. We need to add page objects first to know their IDs,
    // but set their Parent after creating the Pages object.
    // To handle this correctly: create Pages object with a placeholder, then update it.
    // Simpler approach: create page objects WITHOUT Parent first, then create Pages,
    // then update each page's dictionary to add the Parent.

    // Step 1: Create all page objects without Parent
    for &(page_w, page_h, image_id, content_id) in &pages_info {
        let page = dictionary! {
            "Type" => "Page",
            "MediaBox" => vec![
                Object::Real(0.0),
                Object::Real(0.0),
                Object::Real(page_w),
                Object::Real(page_h),
            ],
            "Contents" => content_id,
            "Resources" => dictionary! {
                "XObject" => dictionary! {
                    format!("Im{}", image_id.0) => image_id,
                },
            },
        };
        let page_id = doc.add_object(page);
        page_ids.push(page_id);
    }

    // Step 2: Create Pages object with Kids pointing to all pages
    let pages = dictionary! {
        "Type" => "Pages",
        "Kids" => page_ids.iter().map(|id| Object::Reference(*id)).collect::<Vec<_>>(),
        "Count" => page_ids.len() as i64,
    };
    let pages_id: ObjectId = doc.add_object(pages);

    // Step 3: Update each page to add the Parent field
    for page_id in &page_ids {
        if let Some(Object::Dictionary(ref mut dict)) = doc.objects.get_mut(page_id) {
            dict.set("Parent", Object::Reference(pages_id));
        }
    }

    // Create catalog
    let catalog = dictionary! {
        "Type" => "Catalog",
        "Pages" => pages_id,
    };
    let catalog_id: ObjectId = doc.add_object(catalog);

    // Explicitly set the Root in the trailer
    doc.trailer.set("Root", Object::Reference(catalog_id));

    doc.save(dest)
        .map_err(|e| format!("Failed to save PDF: {e}"))?;

    Ok(())
}

fn calculate_page_dimensions(
    img_w: f32,
    img_h: f32,
    page_size: PageSize,
    orientation: Orientation,
    margin: f32,
) -> (f32, f32) {
    const A4_W: f32 = 595.28;
    const A4_H: f32 = 841.89;
    const LETTER_W: f32 = 612.0;
    const LETTER_H: f32 = 792.0;

    let (base_w, base_h) = match page_size {
        PageSize::Auto => {
            let max_dim = 1200.0;
            let w = img_w.min(max_dim);
            let h = img_h.min(max_dim);
            (w + margin * 2.0, h + margin * 2.0)
        }
        PageSize::A4 => (A4_W, A4_H),
        PageSize::Letter => (LETTER_W, LETTER_H),
    };

    match orientation {
        Orientation::Auto => {
            if img_w > img_h {
                if base_w < base_h {
                    (base_h, base_w)
                } else {
                    (base_w, base_h)
                }
            } else if base_w > base_h {
                (base_h, base_w)
            } else {
                (base_w, base_h)
            }
        }
        Orientation::Portrait => {
            if base_w > base_h {
                (base_h, base_w)
            } else {
                (base_w, base_h)
            }
        }
        Orientation::Landscape => {
            if base_h > base_w {
                (base_h, base_w)
            } else {
                (base_w, base_h)
            }
        }
    }
}

fn calculate_image_placement(
    img_w: f32,
    img_h: f32,
    page_w: f32,
    page_h: f32,
    margin: f32,
    fit: ImageFit,
) -> (f32, f32, f32, f32) {
    let available_w = page_w - margin * 2.0;
    let available_h = page_h - margin * 2.0;

    if available_w <= 0.0 || available_h <= 0.0 {
        return (margin, margin, img_w.min(page_w), img_h.min(page_h));
    }

    let (draw_w, draw_h) = match fit {
        ImageFit::Contain => {
            let scale = (available_w / img_w).min(available_h / img_h).min(1.0);
            (img_w * scale, img_h * scale)
        }
        ImageFit::Cover => {
            let scale = (available_w / img_w).max(available_h / img_h).min(1.0);
            (img_w * scale, img_h * scale)
        }
        ImageFit::Stretch => (available_w, available_h),
    };

    let x = margin + (available_w - draw_w) / 2.0;
    let y = margin + (available_h - draw_h) / 2.0;

    (x, y, draw_w, draw_h)
}
