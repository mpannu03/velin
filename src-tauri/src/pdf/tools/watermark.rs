use image::{codecs::jpeg::JpegEncoder, EncodableLayout, GenericImageView, ImageEncoder};
use lopdf::{Dictionary, Document, Object, Stream};
use serde::Deserialize;

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct WatermarkInput {
    pub input_path: String,
    pub output_path: String,
    pub watermark_type: String,
    pub text: Option<String>,
    pub font_size: Option<f64>,
    pub font_color: Option<String>,
    pub image_path: Option<String>,
    pub image_scale: Option<f64>,
    pub opacity: f64,
    pub rotation: f64,
    pub position: String,
    pub x_offset: Option<f64>,
    pub y_offset: Option<f64>,
    pub pages: Option<String>,
}

fn parse_hex_color(hex: &str) -> Result<(f64, f64, f64), String> {
    let hex = hex.trim_start_matches('#');
    if hex.len() != 6 {
        return Err("Invalid hex color format. Use #RRGGBB.".into());
    }
    let r = u8::from_str_radix(&hex[0..2], 16).map_err(|_| "Invalid hex color")?;
    let g = u8::from_str_radix(&hex[2..4], 16).map_err(|_| "Invalid hex color")?;
    let b = u8::from_str_radix(&hex[4..6], 16).map_err(|_| "Invalid hex color")?;
    Ok((r as f64 / 255.0, g as f64 / 255.0, b as f64 / 255.0))
}

fn parse_page_selection(expr: &str, total_pages: u32) -> Result<Vec<u32>, String> {
    let mut pages = Vec::new();
    for part in expr.split(',') {
        let part = part.trim();
        if part.is_empty() {
            continue;
        }
        if let Some((start, end)) = part.split_once('-') {
            let start: u32 = start
                .trim()
                .parse()
                .map_err(|_| format!("Invalid page number: {}", start))?;
            let end: u32 = end
                .trim()
                .parse()
                .map_err(|_| format!("Invalid page number: {}", end))?;
            if start < 1 || end > total_pages || start > end {
                return Err(format!(
                    "Invalid page range: {}-{} (total pages: {})",
                    start, end, total_pages
                ));
            }
            for p in start..=end {
                pages.push(p);
            }
        } else {
            let page: u32 = part
                .parse()
                .map_err(|_| format!("Invalid page number: {}", part))?;
            if page < 1 || page > total_pages {
                return Err(format!(
                    "Invalid page number: {} (total pages: {})",
                    page, total_pages
                ));
            }
            pages.push(page);
        }
    }
    pages.sort();
    pages.dedup();
    Ok(pages)
}

fn get_media_box(doc: &Document, page_id: lopdf::ObjectId) -> (f64, f64, f64, f64) {
    if let Ok(page) = doc.get_object(page_id) {
        if let Ok(dict) = page.as_dict() {
            if let Ok(Object::Array(arr)) = dict.get(b"MediaBox") {
                if arr.len() >= 4 {
                    let x = arr[0].as_i64().unwrap_or(0) as f64;
                    let y = arr[1].as_i64().unwrap_or(0) as f64;
                    let w = arr[2].as_i64().unwrap_or(612) as f64;
                    let h = arr[3].as_i64().unwrap_or(792) as f64;
                    return (x, y, w, h);
                }
            }
        }
    }
    (0.0, 0.0, 612.0, 792.0)
}

pub fn watermark_pdf(input: WatermarkInput) -> Result<(), String> {
    let mut doc =
        Document::load(&input.input_path).map_err(|e| format!("Failed to load PDF: {}", e))?;

    let pages = doc.get_pages();
    let page_count = pages.len() as u32;

    let target_page_nums: Vec<u32> = match &input.pages {
        Some(expr) if !expr.trim().is_empty() => parse_page_selection(expr, page_count)?,
        _ => (1..=page_count).collect(),
    };

    let gs_name = b"WmGS";

    match input.watermark_type.as_str() {
        "text" => add_text_watermark(&mut doc, &input, &target_page_nums, gs_name)?,
        "image" => add_image_watermark(&mut doc, &input, &target_page_nums, gs_name)?,
        _ => return Err("Invalid watermark type. Use 'text' or 'image'.".into()),
    }

    doc.save(&input.output_path)
        .map_err(|e| format!("Failed to save PDF: {}", e))?;

    Ok(())
}

fn add_text_watermark(
    doc: &mut Document,
    input: &WatermarkInput,
    target_page_nums: &[u32],
    gs_name: &[u8],
) -> Result<(), String> {
    let text = input.text.as_deref().unwrap_or("Watermark");
    let font_size = input.font_size.unwrap_or(48.0);
    let rotation_deg = input.rotation;
    let rotation_rad = rotation_deg.to_radians();
    let (r, g, b) = match &input.font_color {
        Some(hex) if !hex.is_empty() => parse_hex_color(hex)?,
        _ => (0.5, 0.5, 0.5),
    };

    let cos = rotation_rad.cos();
    let sin = rotation_rad.sin();
    let opacity = input.opacity.clamp(0.0, 1.0);

    let pages = doc.get_pages();

    for page_num in target_page_nums {
        let page_id = pages
            .get(page_num)
            .ok_or_else(|| format!("Page {} not found", page_num))?;

        let (media_x, media_y, page_width, page_height) = get_media_box(doc, *page_id);

        let (pos_x, pos_y) = calculate_position(
            &input.position,
            input.x_offset,
            input.y_offset,
            page_width - media_x,
            page_height - media_y,
            text.len() as f64 * font_size * 0.5,
            font_size,
        );

        let content = format!(
            "q\n\
             /{} gs\n\
             BT\n\
             /F1 {} Tf\n\
             {} {} {} rg\n\
             {} {} {} {} {} {} Tm\n\
             ({}) Tj\n\
             ET\n\
             Q\n",
            std::str::from_utf8(gs_name).unwrap_or("WmGS"),
            format_f64(font_size),
            format_f64(r),
            format_f64(g),
            format_f64(b),
            format_f64(cos),
            format_f64(sin),
            format_f64(-sin),
            format_f64(cos),
            format_f64(pos_x),
            format_f64(pos_y),
            escape_pdf_string(text),
        );

        inject_text_content_stream(doc, *page_id, content.as_bytes(), gs_name, opacity as f32)?;
    }

    Ok(())
}

fn add_image_watermark(
    doc: &mut Document,
    input: &WatermarkInput,
    target_page_nums: &[u32],
    gs_name: &[u8],
) -> Result<(), String> {
    let image_path = input
        .image_path
        .as_deref()
        .ok_or_else(|| "Image path is required for image watermark.".to_string())?;
    let scale = input.image_scale.unwrap_or(0.5).clamp(0.01, 2.0);

    let img =
        image::open(image_path).map_err(|e| format!("Failed to load watermark image: {}", e))?;

    let (img_w, img_h) = img.dimensions();
    let display_w = (img_w as f64 * scale).round() as u32;
    let display_h = (img_h as f64 * scale).round() as u32;

    let rotation_deg = input.rotation;
    let rotation_rad = rotation_deg.to_radians();
    let cos = rotation_rad.cos();
    let sin = rotation_rad.sin();
    let opacity = input.opacity.clamp(0.0, 1.0);

    // Resize and encode image
    let rgb_img = img.to_rgb8();
    let (resized_w, resized_h, jpeg_bytes) = if (scale - 1.0).abs() > 0.01 {
        let resized = image::imageops::resize(
            &rgb_img,
            display_w.max(1),
            display_h.max(1),
            image::imageops::FilterType::Lanczos3,
        );
        let (w, h) = resized.dimensions();
        let mut buf = Vec::new();
        let encoder = JpegEncoder::new_with_quality(&mut buf, 85);
        encoder
            .write_image(resized.as_bytes(), w, h, image::ExtendedColorType::Rgb8)
            .map_err(|e| format!("Failed to encode watermark image: {}", e))?;
        (w, h, buf)
    } else {
        let mut buf = Vec::new();
        let encoder = JpegEncoder::new_with_quality(&mut buf, 85);
        encoder
            .write_image(
                rgb_img.as_bytes(),
                img_w,
                img_h,
                image::ExtendedColorType::Rgb8,
            )
            .map_err(|e| format!("Failed to encode watermark image: {}", e))?;
        (img_w, img_h, buf)
    };

    // Create the image XObject stream
    let img_stream = Stream::new(
        Dictionary::from_iter(vec![
            ("Type", Object::Name(b"XObject".to_vec())),
            ("Subtype", Object::Name(b"Image".to_vec())),
            ("Width", Object::Integer(resized_w as i64)),
            ("Height", Object::Integer(resized_h as i64)),
            ("ColorSpace", Object::Name(b"DeviceRGB".to_vec())),
            ("BitsPerComponent", Object::Integer(8)),
            ("Filter", Object::Name(b"DCTDecode".to_vec())),
        ]),
        jpeg_bytes,
    );

    let img_stream_id = doc.add_object(Object::Stream(img_stream));
    let img_ref = Object::Reference(img_stream_id);

    let pages = doc.get_pages();

    for page_num in target_page_nums {
        let page_id = pages
            .get(page_num)
            .ok_or_else(|| format!("Page {} not found", page_num))?;

        let (media_x, media_y, page_width, page_height) = get_media_box(doc, *page_id);

        let (pos_x, pos_y) = calculate_position(
            &input.position,
            input.x_offset,
            input.y_offset,
            page_width - media_x,
            page_height - media_y,
            resized_w as f64,
            resized_h as f64,
        );

        let img_name = b"WmImg";

        let content = format!(
            "q\n\
             /{} gs\n\
             {} {} {} {} {} {} cm\n\
             /{} Do\n\
             Q\n",
            std::str::from_utf8(gs_name).unwrap_or("WmGS"),
            format_f64(cos * resized_w as f64),
            format_f64(sin * resized_h as f64),
            format_f64(-sin * resized_w as f64),
            format_f64(cos * resized_h as f64),
            format_f64(pos_x),
            format_f64(pos_y),
            std::str::from_utf8(img_name).unwrap_or("WmImg"),
        );

        inject_image_content_stream(
            doc,
            *page_id,
            content.as_bytes(),
            gs_name,
            img_name,
            &img_ref,
            opacity as f32,
        )?;
    }

    Ok(())
}

fn calculate_position(
    position: &str,
    x_offset: Option<f64>,
    y_offset: Option<f64>,
    page_width: f64,
    page_height: f64,
    obj_width: f64,
    obj_height: f64,
) -> (f64, f64) {
    let offset_x = x_offset.unwrap_or(0.0);
    let offset_y = y_offset.unwrap_or(0.0);
    let margin = 40.0;

    match position {
        "top-left" => (
            margin + offset_x,
            page_height - obj_height - margin - offset_y,
        ),
        "top-right" => (
            page_width - obj_width - margin - offset_x,
            page_height - obj_height - margin - offset_y,
        ),
        "bottom-left" => (margin + offset_x, margin + offset_y),
        "bottom-right" => (
            page_width - obj_width - margin - offset_x,
            margin + offset_y,
        ),
        "center" | _ => (
            (page_width - obj_width) / 2.0 + offset_x,
            (page_height - obj_height) / 2.0 + offset_y,
        ),
    }
}

fn inject_text_content_stream(
    doc: &mut Document,
    page_id: lopdf::ObjectId,
    content_bytes: &[u8],
    gs_name: &[u8],
    opacity: f32,
) -> Result<(), String> {
    let watermark_stream = Stream::new(
        Dictionary::from_iter(vec![(
            "Length",
            Object::Integer(content_bytes.len() as i64),
        )]),
        content_bytes.to_vec(),
    );
    let watermark_id = doc.add_object(Object::Stream(watermark_stream));

    if let Ok(page) = doc.get_object_mut(page_id) {
        if let Ok(dict) = page.as_dict_mut() {
            // Ensure /Resources exists
            if !dict.has(b"Resources") {
                dict.set("Resources", Object::Dictionary(Dictionary::new()));
            }

            if let Ok(Object::Dictionary(res_dict)) = dict.get_mut(b"Resources") {
                // Add ExtGState
                if !res_dict.has(b"ExtGState") {
                    res_dict.set(b"ExtGState".to_vec(), Object::Dictionary(Dictionary::new()));
                }

                if let Ok(Object::Dictionary(gs_dict)) = res_dict.get_mut(b"ExtGState") {
                    gs_dict.set(
                        gs_name.to_vec(),
                        Object::Dictionary(Dictionary::from_iter(vec![
                            (b"Type".to_vec(), Object::Name(b"ExtGState".to_vec())),
                            (b"ca".to_vec(), Object::Real(opacity)),
                            (b"CA".to_vec(), Object::Real(opacity)),
                            (b"AIS".to_vec(), Object::Boolean(false)),
                            (b"BM".to_vec(), Object::Name(b"Normal".to_vec())),
                        ])),
                    );
                }

                // Add Font
                if !res_dict.has(b"Font") {
                    res_dict.set(b"Font".to_vec(), Object::Dictionary(Dictionary::new()));
                }

                if let Ok(Object::Dictionary(font_dict)) = res_dict.get_mut(b"Font") {
                    if !font_dict.has(b"F1") {
                        font_dict.set(
                            b"F1".to_vec(),
                            Object::Dictionary(Dictionary::from_iter(vec![
                                (b"Type".to_vec(), Object::Name(b"Font".to_vec())),
                                (b"Subtype".to_vec(), Object::Name(b"Type1".to_vec())),
                                (b"BaseFont".to_vec(), Object::Name(b"Helvetica".to_vec())),
                                (
                                    b"Encoding".to_vec(),
                                    Object::Name(b"WinAnsiEncoding".to_vec()),
                                ),
                            ])),
                        );
                    }
                }
            }

            // Handle Contents
            match dict.get(b"Contents") {
                Ok(Object::Reference(existing_id)) => {
                    dict.set(
                        b"Contents",
                        Object::Array(vec![
                            Object::Reference(watermark_id),
                            Object::Reference(*existing_id),
                        ]),
                    );
                }
                Ok(Object::Array(existing_arr)) => {
                    let mut new_arr = vec![Object::Reference(watermark_id)];
                    new_arr.extend(existing_arr.iter().cloned());
                    dict.set(b"Contents", Object::Array(new_arr));
                }
                _ => {
                    dict.set(b"Contents", Object::Reference(watermark_id));
                }
            }
        }
    }

    Ok(())
}

fn inject_image_content_stream(
    doc: &mut Document,
    page_id: lopdf::ObjectId,
    content_bytes: &[u8],
    gs_name: &[u8],
    img_name: &[u8],
    img_ref: &Object,
    opacity: f32,
) -> Result<(), String> {
    let watermark_stream = Stream::new(
        Dictionary::from_iter(vec![(
            "Length",
            Object::Integer(content_bytes.len() as i64),
        )]),
        content_bytes.to_vec(),
    );
    let watermark_id = doc.add_object(Object::Stream(watermark_stream));

    if let Ok(page) = doc.get_object_mut(page_id) {
        if let Ok(dict) = page.as_dict_mut() {
            // Ensure /Resources exists
            if !dict.has(b"Resources") {
                dict.set("Resources", Object::Dictionary(Dictionary::new()));
            }

            if let Ok(Object::Dictionary(res_dict)) = dict.get_mut(b"Resources") {
                // Add ExtGState
                if !res_dict.has(b"ExtGState") {
                    res_dict.set(b"ExtGState".to_vec(), Object::Dictionary(Dictionary::new()));
                }

                if let Ok(Object::Dictionary(gs_dict)) = res_dict.get_mut(b"ExtGState") {
                    gs_dict.set(
                        gs_name.to_vec(),
                        Object::Dictionary(Dictionary::from_iter(vec![
                            (b"Type".to_vec(), Object::Name(b"ExtGState".to_vec())),
                            (b"ca".to_vec(), Object::Real(opacity)),
                            (b"CA".to_vec(), Object::Real(opacity)),
                            (b"AIS".to_vec(), Object::Boolean(false)),
                            (b"BM".to_vec(), Object::Name(b"Normal".to_vec())),
                        ])),
                    );
                }

                // Add XObject
                if !res_dict.has(b"XObject") {
                    res_dict.set(b"XObject".to_vec(), Object::Dictionary(Dictionary::new()));
                }

                if let Ok(Object::Dictionary(xobj_dict)) = res_dict.get_mut(b"XObject") {
                    xobj_dict.set(img_name.to_vec(), img_ref.clone());
                }
            }

            // Handle Contents
            match dict.get(b"Contents") {
                Ok(Object::Reference(existing_id)) => {
                    dict.set(
                        b"Contents",
                        Object::Array(vec![
                            Object::Reference(watermark_id),
                            Object::Reference(*existing_id),
                        ]),
                    );
                }
                Ok(Object::Array(existing_arr)) => {
                    let mut new_arr = vec![Object::Reference(watermark_id)];
                    new_arr.extend(existing_arr.iter().cloned());
                    dict.set(b"Contents", Object::Array(new_arr));
                }
                _ => {
                    dict.set(b"Contents", Object::Reference(watermark_id));
                }
            }
        }
    }

    Ok(())
}

fn escape_pdf_string(s: &str) -> String {
    let mut escaped = String::with_capacity(s.len());
    for c in s.chars() {
        match c {
            '(' => escaped.push_str(r"\("),
            ')' => escaped.push_str(r"\)"),
            '\\' => escaped.push_str(r"\\"),
            '\n' => escaped.push_str(r"\n"),
            '\r' => escaped.push_str(r"\r"),
            '\t' => escaped.push_str(r"\t"),
            '\u{8}' => escaped.push_str(r"\b"),
            '\u{12}' => escaped.push_str(r"\f"),
            c if c.is_ascii() && !c.is_control() => escaped.push(c),
            _ => {
                for b in c.encode_utf16(&mut [0u16; 2]) {
                    escaped.push_str(&format!("\\u{:04X}", b));
                }
            }
        }
    }
    escaped
}

fn format_f64(value: f64) -> String {
    if value == value.trunc() {
        format!("{:.1}", value)
    } else {
        format!("{:.4}", value)
    }
}
