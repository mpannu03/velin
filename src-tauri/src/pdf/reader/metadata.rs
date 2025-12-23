// use crate::pdf::document::PdfDocument;

// /// Reads and caches the total page count of the document.
// ///
// /// Requires the PDF to be loaded via `loader::load_pdf`.
// pub fn page_count(document: &mut PdfDocument) -> Result<u32, String> {
//     // If already cached, return it
//     if let Some(count) = document.page_count {
//         return Ok(count);
//     }

//     // Lock inner state for reading
//     let inner = document.inner.read();

//     let pdfium = inner
//         .pdfiumHandle
//         .as_ref()
//         .ok_or("PDF is not loaded")?;

//     // ---- pdfium usage placeholder ----
//     // Later this will be:
//     let count = pdfium.doc.pages().len() as u32;

//     drop(inner); // explicit: release lock early

//     // Cache result
//     document.page_count = Some(count);

//     Ok(count)
// }
