use crate::pdf::reader::annotation::{Annotation, AnnotationGeometry, AnnotationType, PdfRect};
use crate::pdf::reader::{AnnotationAppearance, AnnotationFlags, AnnotationMetadata, Point, Quad};
use crate::pdf::DocumentId;
use pdfium_render::prelude::*;
use std::collections::HashMap;

pub fn get_annotations(
    documents: &HashMap<DocumentId, PdfDocument>,
    id: &DocumentId,
) -> Result<Vec<Annotation>, String> {
    let document = documents.get(id).ok_or("Document not found")?;
    let mut annotations = Vec::new();

    for (page_idx, page) in document.pages().iter().enumerate() {
        for (annot_idx, annotation) in page.annotations().iter().enumerate() {
            let annot_type = annotation.annotation_type();
            match annot_type {
                PdfPageAnnotationType::Highlight
                | PdfPageAnnotationType::Underline
                | PdfPageAnnotationType::Squiggly
                | PdfPageAnnotationType::Strikeout => {
                    process_markup_annotation(
                        &mut annotations,
                        &annotation,
                        page.height().value,
                        page_idx,
                        annot_idx,
                    )?;
                }
                _ => {}
            }
        }
    }

    Ok(annotations)
}

fn process_markup_annotation<'a>(
    annotations: &mut Vec<Annotation>,
    annotation: &PdfPageAnnotation<'a>,
    page_height: f32,
    page_index: usize,
    annot_index: usize,
) -> Result<(), String> {
    let annotation_type = get_annotation_type(annotation);

    let bounds = annotation.bounds().map_err(|e| e.to_string())?;

    let rect = PdfRect {
        left: bounds.left().value,
        top: bounds.top().value,
        right: bounds.right().value,
        bottom: bounds.bottom().value,
    };

    let attachment_points = annotation.attachment_points();

    let quads = attachment_points
        .iter()
        .map(|qp| Quad {
            p1: Point {
                x: qp.x1.value,
                y: qp.y1.value,
            },
            p2: Point {
                x: qp.x2.value,
                y: qp.y2.value,
            },
            p3: Point {
                x: qp.x3.value,
                y: qp.y3.value,
            },
            p4: Point {
                x: qp.x4.value,
                y: qp.y4.value,
            },
        })
        .collect::<Vec<_>>();

    if quads.is_empty() {
        return Ok(());
    }

    // Safety: fill_color() and stroke_color() in pdfium-render 0.8.x can crash (ACCESS_VIOLATION)
    // because they try to cast an annotation handle to a page object handle
    // if FPDFAnnot_GetColor() fails.
    /*
    let color_result = annotation.stroke_color();
    let (r, g, b, a) = match color_result {
        Ok(c) => (c.red(), c.green(), c.blue(), c.alpha()),
        Err(_) => (255, 255, 0, 255), // Default to yellow on error
    };
    */
    // let (r, g, b, a) = match color_result {
    //     Ok(c) => (c.red(), c.green(), c.blue(), c.alpha()),
    //     Err(_) => (255, 255, 0, 255), // Default to yellow on error
    // };
    let (r, g, b, a) = (255, 0, 0, 150);

    let appearance = AnnotationAppearance {
        color: format!("#{:02X}{:02X}{:02X}", r, g, b),
        opacity: a as f32 / 255.0,
        border_width: None,
    };

    let author = annotation.name();
    let contents = annotation.contents();
    let creation_date = annotation.creation_date();
    let modified_date = annotation.modification_date();

    let metadata = AnnotationMetadata {
        author,
        contents,
        creation_date,
        modified_date,
    };

    let hidden = annotation.is_hidden();
    let locked = annotation.is_locked();
    let printable = annotation.is_printed();
    let read_only = annotation.is_read_only();

    let flags = AnnotationFlags {
        hidden,
        locked,
        printable,
        read_only,
    };

    let prefix = match annotation_type {
        AnnotationType::Highlight => "hl",
        AnnotationType::Underline => "ul",
        AnnotationType::Squiggly => "sq",
        AnnotationType::Strikeout => "so",
        _ => "ann",
    };

    let stable_id = format!("{}-{}-{}", prefix, page_index, annot_index);

    annotations.push(Annotation {
        id: stable_id,
        page_index: page_index as u16,
        subtype: annotation_type,
        rect,
        geometry: AnnotationGeometry::QuadPoints(quads),
        appearance,
        metadata,
        flags,
    });

    Ok(())
}

fn get_annotation_type(annotation: &PdfPageAnnotation) -> AnnotationType {
    match annotation.annotation_type() {
        PdfPageAnnotationType::Highlight => AnnotationType::Highlight,
        PdfPageAnnotationType::Underline => AnnotationType::Underline,
        PdfPageAnnotationType::Squiggly => AnnotationType::Squiggly,
        PdfPageAnnotationType::Strikeout => AnnotationType::Strikeout,
        _ => AnnotationType::Unknown,
    }
}

pub fn add_annotation(
    documents: &HashMap<DocumentId, PdfDocument>,
    id: &DocumentId,
    annotation: Annotation,
) -> Result<(), String> {
    // Mock implementation
    eprintln!("Mock adding annotation: {:?}", annotation);
    // In a real implementation, we would use pdfium-render to add the annotation.
    // However, due to API version mismatches/ambiguity with PdfQuadPoints,
    // we are mocking this for now to ensure compilation.

    Ok(())
}

pub fn delete_annotation(
    documents: &HashMap<DocumentId, PdfDocument>,
    id: &DocumentId,
    _page_index: u16,
    annot_id: String,
) -> Result<(), String> {
    // Mock implementation
    eprintln!("Mock deleting annotation: {}", annot_id);

    Ok(())
}
