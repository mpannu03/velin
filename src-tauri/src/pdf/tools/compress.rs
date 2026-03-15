use image::{DynamicImage, GenericImageView, ImageEncoder};
use lopdf::{Document, Object, Stream};
use std::io::Cursor;

fn quality_params(quality: u8) -> (u8, f32) {
    let jpeg_q = match quality {
        0..=30 => 1 + (quality as f32 * 0.1) as u8,
        31..=60 => 4 + ((quality - 30) as f32 * 0.5) as u8,
        61..=80 => 20 + ((quality - 60) as f32 * 1.5) as u8,
        81..=94 => 51 + ((quality - 80) as f32 * 2.0) as u8,
        _ => 80 + ((quality - 94) as f32 * 2.5) as u8,
    }
    .clamp(1, 95);

    let scale = if quality >= 98 {
        1.0
    } else {
        match quality {
            0..=20 => 0.1 + (quality as f32 * 0.005),
            21..=40 => 0.2 + ((quality - 20) as f32 * 0.01),
            41..=60 => 0.4 + ((quality - 40) as f32 * 0.01),
            61..=80 => 0.6 + ((quality - 60) as f32 * 0.015),
            _ => 0.9 + ((quality - 80) as f32 * 0.005).min(0.1),
        }
        .clamp(0.1, 1.0)
    };

    (jpeg_q, scale)
}

fn decode_pdf_image(stream: &mut Stream) -> Option<DynamicImage> {
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
        return image::load_from_memory(&stream.content).ok();
    }

    if is_flate {
        let mut tmp = stream.clone();
        tmp.decompress().ok()?;

        let w = tmp.dict.get(b"Width").and_then(|o| o.as_i64()).unwrap_or(0) as u32;
        let h = tmp
            .dict
            .get(b"Height")
            .and_then(|o| o.as_i64())
            .unwrap_or(0) as u32;
        let bpc = tmp
            .dict
            .get(b"BitsPerComponent")
            .and_then(|o| o.as_i64())
            .unwrap_or(8);

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
            // Convert CMYK → RGB
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

fn encode_as_jpeg(img: &DynamicImage, jpeg_quality: u8) -> Option<Vec<u8>> {
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
    let encoder = image::codecs::jpeg::JpegEncoder::new_with_quality(&mut buf, jpeg_quality);
    encoder
        .write_image(
            img_to_encode.as_bytes(),
            img_to_encode.width(),
            img_to_encode.height(),
            img_to_encode.color().into(),
        )
        .ok()?;
    Some(buf.into_inner())
}

fn stream_is_compressed(stream: &Stream) -> bool {
    if let Ok(filter) = stream.dict.get(b"Filter") {
        if let Ok(name) = filter.as_name() {
            return matches!(
                name,
                b"FlateDecode"
                    | b"DCTDecode"
                    | b"LZWDecode"
                    | b"CCITTFaxDecode"
                    | b"JBIG2Decode"
                    | b"JPXDecode"
            );
        }
        if let Ok(arr) = filter.as_array() {
            return !arr.is_empty();
        }
    }
    false
}

pub fn compress(input_path: &str, output_path: &str, quality: u8) -> Result<(), String> {
    let mut doc = Document::load(input_path).map_err(|e| format!("Failed to load PDF: {}", e))?;

    // Remove unused objects — cheap, always helps
    doc.prune_objects();

    if quality < 100 {
        use rayon::prelude::*;

        let (jpeg_quality, scale) = quality_params(quality);

        let objects: Vec<_> = doc.objects.iter().collect();

        let replacements: Vec<_> = objects
            .par_iter()
            .filter_map(|(object_id, object)| {
                let stream = match object {
                    Object::Stream(s) => s,
                    _ => return None,
                };

                // Only image XObjects
                let subtype = stream.dict.get(b"Subtype").ok()?;
                if subtype.as_name().ok()? != b"Image" {
                    return None;
                }

                if stream
                    .dict
                    .get(b"ImageMask")
                    .and_then(|o| o.as_bool())
                    .unwrap_or(false)
                {
                    return None;
                }

                let original_encoded_len = stream.content.len();

                // Clone to safely decompress without mutating the document
                let mut own_stream = stream.clone();
                let img = decode_pdf_image(&mut own_stream)?;

                let (orig_w, orig_h) = img.dimensions();

                // Resize if scale < 1.0
                let new_w = ((orig_w as f32 * scale).round() as u32).max(1);
                let new_h = ((orig_h as f32 * scale).round() as u32).max(1);

                let resized = if new_w < orig_w || new_h < orig_h {
                    img.resize_exact(new_w, new_h, image::imageops::FilterType::Lanczos3)
                } else {
                    img
                };

                let jpeg_bytes = encode_as_jpeg(&resized, jpeg_quality)?;

                // Only replace if the resulting JPEG is strictly smaller than the
                // original encoded stream (whether FlateDecode or DCTDecode).
                if jpeg_bytes.len() >= original_encoded_len {
                    return None;
                }

                Some((**object_id, jpeg_bytes, new_w, new_h))
            })
            .collect();

        for (object_id, jpeg_bytes, new_w, new_h) in replacements {
            if let Some(Object::Stream(stream)) = doc.objects.get_mut(&object_id) {
                stream.content = jpeg_bytes;
                stream
                    .dict
                    .set("Length", Object::Integer(stream.content.len() as i64));
                stream.dict.set("Width", Object::Integer(new_w as i64));
                stream.dict.set("Height", Object::Integer(new_h as i64));
                stream
                    .dict
                    .set("Filter", Object::Name(b"DCTDecode".to_vec()));
                stream.dict.remove(b"DecodeParms");
                stream.dict.remove(b"SMask");
                stream.dict.set("BitsPerComponent", Object::Integer(8));
            }
        }

        let uncompressed_ids: Vec<_> = doc
            .objects
            .iter()
            .filter_map(|(id, obj)| {
                if let Object::Stream(s) = obj {
                    let is_image = s
                        .dict
                        .get(b"Subtype")
                        .and_then(|o| o.as_name())
                        .map(|n| n == b"Image")
                        .unwrap_or(false);
                    if is_image {
                        return None;
                    }
                    // Only compress streams that have no filter yet
                    if !stream_is_compressed(s) {
                        return Some(*id);
                    }
                }
                None
            })
            .collect();

        for id in uncompressed_ids {
            if let Some(Object::Stream(stream)) = doc.objects.get_mut(&id) {
                let _ = stream.compress();
            }
        }
    }

    doc.save(output_path)
        .map_err(|e| format!("Failed to save PDF: {}", e))?;

    Ok(())
}
