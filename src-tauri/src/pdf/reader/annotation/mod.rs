use serde::{Deserialize, Serialize};

pub mod annotations;

pub use annotations::*;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(tag = "type", content = "data", rename_all = "lowercase")]
pub enum AnnotationGeometry {
    /// Used by simple rectangle-based annotations (Text, Square, Circle, etc.)
    Rect(PdfRect),

    /// Used by text markup annotations (Highlight, Underline, etc.)
    QuadPoints(Vec<Quad>),

    /// Used by ink annotations (freehand drawing)
    InkPaths(Vec<Vec<Point>>),

    /// Used by line annotation
    Line { start: Point, end: Point },

    /// Used by polygon/polyline annotations
    Points(Vec<Point>),
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Quad {
    pub p1: Point,
    pub p2: Point,
    pub p3: Point,
    pub p4: Point,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Point {
    pub x: f32,
    pub y: f32,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct PdfRect {
    pub left: f32,
    pub top: f32,
    pub right: f32,
    pub bottom: f32,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum AnnotationType {
    Unknown,
    Text,
    Link,
    FreeText,
    Line,
    Square,
    Circle,
    Polygon,
    Polyline,
    Highlight,
    Underline,
    Squiggly,
    Strikeout,
    Stamp,
    Caret,
    Ink,
    Popup,
    FileAttachment,
    Sound,
    Movie,
    Widget,
    Screen,
    PrinterMark,
    TrapNet,
    Watermark,
    ThreeD,
    RichMedia,
    XfaWidget,
    Redacted,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnnotationAppearance {
    pub color: String,
    pub opacity: f32,
    pub border_width: Option<f32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnnotationMetadata {
    pub author: Option<String>,
    pub contents: Option<String>,
    pub creation_date: Option<String>,
    pub modified_date: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AnnotationFlags {
    pub hidden: bool,
    pub locked: bool,
    pub printable: bool,
    pub read_only: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Annotation {
    pub id: String,
    pub page_index: u16,

    /// PDF annotation subtype
    pub subtype: AnnotationType,

    /// Mandatory bounding box (PDF requires this)
    pub rect: PdfRect,

    /// Actual geometry (depends on subtype)
    pub geometry: AnnotationGeometry,

    /// Visual styling
    pub appearance: AnnotationAppearance,

    /// Metadata & comments
    pub metadata: AnnotationMetadata,

    /// Annotation behavior flags
    pub flags: AnnotationFlags,
}
