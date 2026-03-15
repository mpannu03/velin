use image::{DynamicImage, GenericImageView, ImageEncoder};
use lopdf::{Document, Object, Stream};
use std::io::Cursor;

/// Scale factor derived from quality (0–100).
/// quality=100 → 1.0 (no downscale)
/// quality=50  → 0.75
/// quality=1   → 0.25
fn scale_for_quality(quality: u8) -> f32 {
    let q = quality.clamp(1, 100) as f32 / 100.0;
    // Linear interpolation: 0.25 at q=0 → 1.0 at q=1
    0.25 + 0.75 * q
}

/// Try to decode a PDF image stream into a DynamicImage.
/// Handles DCTDecode (JPEG) and FlateDecode (raw pixels) with RGB/Gray color spaces.
fn decode_pdf_image(stream: &mut Stream) -> Option<DynamicImage> {
    // Determine filter(s)
    let filter = stream.dict.get(b"Filter").ok()?;
    let mut is_jpeg = false;
    let mut is_flate = false;

    if let Ok(name) = filter.as_name() {
        match name {
            b"DCTDecode" => is_jpeg = true,
            b"FlateDecode" => is_flate = true,
            _ => {}
        }
    } else if let Ok(arr) = filter.as_array() {
        for f in arr {
            if let Ok(n) = f.as_name() {
                match n {
                    b"DCTDecode" => {
                        is_jpeg = true;
                        break;
                    }
                    b"FlateDecode" => is_flate = true,
                    _ => {}
                }
            }
        }
    }

    if is_jpeg {
        // JPEG: content is self-contained JPEG bytes
        return image::load_from_memory(&stream.content).ok();
    }

    if is_flate {
        // Decompress the stream to get raw pixel bytes
        let mut tmp = stream.clone();
        tmp.decompress().ok()?;

        let w = tmp.dict.get(b"Width").and_then(|o| o.as_i64()).unwrap_or(0) as u32;
        let h = tmp.dict.get(b"Height").and_then(|o| o.as_i64()).unwrap_or(0) as u32;
        let bpc = tmp.dict.get(b"BitsPerComponent").and_then(|o| o.as_i64()).unwrap_or(8);

        if w == 0 || h == 0 || bpc != 8 {
            return None;
        }

        let cs = match tmp.dict.get(b"ColorSpace") {
            Ok(Object::Name(n)) => n.clone(),
            _ => return None,
        };

        let data = tmp.content;

        if cs == b"DeviceRGB" && data.len() == (w * h * 3) as usize {
            let rgb = image::RgbImage::from_raw(w, h, data)?;
            return Some(DynamicImage::ImageRgb8(rgb));
        }

        if cs == b"DeviceGray" && data.len() == (w * h) as usize {
            let gray = image::GrayImage::from_raw(w, h, data)?;
            return Some(DynamicImage::ImageLuma8(gray));
        }

        if cs == b"DeviceCMYK" && data.len() == (w * h * 4) as usize {
            // Convert CMYK → RGB manually
            let mut rgb_data = Vec::with_capacity((w * h * 3) as usize);
            for chunk in data.chunks_exact(4) {
                let c = chunk[0] as f32 / 255.0;
                let m = chunk[1] as f32 / 255.0;
                let y = chunk[2] as f32 / 255.0;
                let k = chunk[3] as f32 / 255.0;
                rgb_data.push(((1.0 - c) * (1.0 - k) * 255.0) as u8);
                rgb_data.push(((1.0 - m) * (1.0 - k) * 255.0) as u8);
                rgb_data.push(((1.0 - y) * (1.0 - k) * 255.0) as u8);
            }
            let rgb = image::RgbImage::from_raw(w, h, rgb_data)?;
            return Some(DynamicImage::ImageRgb8(rgb));
        }
    }

    None
}

/// Re-encode a DynamicImage as JPEG at the given quality.
/// Drops alpha channel (JPEG doesn't support transparency).
fn encode_as_jpeg(img: &DynamicImage, quality: u8) -> Option<Vec<u8>> {
    // JPEG doesn't support alpha – convert to RGB or Gray
    let img_to_encode: DynamicImage = match img {
        DynamicImage::ImageRgba8(_) | DynamicImage::ImageRgba16(_) => {
            DynamicImage::ImageRgb8(img.to_rgb8())
        }
        DynamicImage::ImageLumaA8(_) | DynamicImage::ImageLumaA16(_) => {
            DynamicImage::ImageLuma8(img.to_luma8())
        }
        _ => img.clone(),
    };

    let mut buf = Cursor::new(Vec::new());
    let encoder = image::codecs::jpeg::JpegEncoder::new_with_quality(&mut buf, quality);
    encoder.write_image(
        img_to_encode.as_bytes(),
        img_to_encode.width(),
        img_to_encode.height(),
        img_to_encode.color().into(),
    ).ok()?;
    Some(buf.into_inner())
}

pub fn compress(input_path: &str, output_path: &str, quality: u8) -> Result<(), String> {
    let mut doc =
        Document::load(input_path).map_err(|e| format!("Failed to load PDF: {}", e))?;

    // Always remove unused objects – cheap and always helps
    doc.prune_objects();

    if quality < 100 {
        use rayon::prelude::*;

        let scale = scale_for_quality(quality);

        // Collect (object_id, new_jpeg_bytes, new_w, new_h) for eligible image streams
        let objects: Vec<_> = doc.objects.iter().collect();

        let replacements: Vec<_> = objects
            .par_iter()
            .filter_map(|(object_id, object)| {
                let stream = match object {
                    Object::Stream(s) => s,
                    _ => return None,
                };

                // Must be an image XObject
                let subtype = stream.dict.get(b"Subtype").ok()?;
                if subtype.as_name().ok()? != b"Image" {
                    return None;
                }

                // Skip masks/inline soft masks
                if stream.dict.get(b"ImageMask").and_then(|o| o.as_bool()).unwrap_or(false) {
                    return None;
                }

                // Clone so we can call decompress() without mutating the doc
                let mut own_stream = stream.clone();
                let img = decode_pdf_image(&mut own_stream)?;

                let (orig_w, orig_h) = img.dimensions();

                // Compute new dimensions
                let new_w = ((orig_w as f32 * scale).round() as u32).max(1);
                let new_h = ((orig_h as f32 * scale).round() as u32).max(1);

                // Resize only if we're actually shrinking
                let resized = if new_w < orig_w || new_h < orig_h {
                    img.resize_exact(new_w, new_h, image::imageops::FilterType::Lanczos3)
                } else {
                    img
                };

                let jpeg_bytes = encode_as_jpeg(&resized, quality)?;

                // Compare against the *decompressed* raw byte count of the original so the
                // comparison is fair: raw pixels vs JPEG-compressed pixels.
                // For a DCTDecode image the original is already JPEG; compare directly.
                let filter = own_stream.dict.get(b"Filter").ok()?;
                let was_jpeg = filter.as_name().map(|n| n == b"DCTDecode").unwrap_or(false)
                    || filter
                        .as_array()
                        .ok()
                        .map(|a| {
                            a.iter()
                                .any(|f| f.as_name().map(|n| n == b"DCTDecode").unwrap_or(false))
                        })
                        .unwrap_or(false);

                // For JPEG->JPEG only replace if we actually save bytes in the JPEG itself.
                // For FlateDecode->JPEG always replace as long as the operation succeeded,
                // because the JPEG will be far smaller than raw pixels.
                if was_jpeg && jpeg_bytes.len() >= stream.content.len() {
                    return None;
                }

                Some((**object_id, jpeg_bytes, new_w, new_h))
            })
            .collect();

        // Apply replacements (single-threaded, mutable borrow)
        for (object_id, jpeg_bytes, new_w, new_h) in replacements {
            if let Some(Object::Stream(stream)) = doc.objects.get_mut(&object_id) {
                stream.content = jpeg_bytes;
                stream.dict.set("Length", Object::Integer(stream.content.len() as i64));
                stream.dict.set("Width", Object::Integer(new_w as i64));
                stream.dict.set("Height", Object::Integer(new_h as i64));
                stream.dict.set("Filter", Object::Name(b"DCTDecode".to_vec()));
                // Remove old decode parameters that belong to FlateDecode
                stream.dict.remove(b"DecodeParms");
                // Remove SMask reference; it's now irrelevant to a JPEG
                stream.dict.remove(b"SMask");
                // Ensure BitsPerComponent is 8 (JPEG is always 8-bit)
                stream.dict.set("BitsPerComponent", Object::Integer(8));
            }
        }
    }

    // Flate-compress all non-image streams (metadata, content streams, etc.)
    doc.compress();

    doc.save(output_path)
        .map_err(|e| format!("Failed to save PDF: {}", e))?;

    Ok(())
}
