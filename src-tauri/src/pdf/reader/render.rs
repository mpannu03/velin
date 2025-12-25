use serde::Serialize;

#[derive(Serialize)]
pub struct RenderedPage {
    pub width: i32,
    pub height: i32,
    pub pixels: Vec<u8>,
}
