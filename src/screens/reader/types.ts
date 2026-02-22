export type RenderedPage = {
  width: number
  height: number
  pixels: Uint8Array
}

export type PdfRect = {
    left: number;
    top: number;
    right: number;
    bottom: number;
}

export type Point = {
    x: number;
    y: number;
}

export type Quad = {
    p1: Point;
    p2: Point;
    p3: Point;
    p4: Point;
}

export type AnnotationGeometry = 
    | { type: "rect"; data: PdfRect }
    | { type: "quadpoints"; data: Quad[] }
    | { type: "inkpaths"; data: Point[][] }
    | { type: "line"; data: { start: Point; end: Point } }
    | { type: "points"; data: Point[] };

export enum AnnotationType {
    Unknown = "unknown",
    Text = "text",
    Link = "link",
    FreeText = "freetext",
    Line = "line",
    Square = "square",
    Circle = "circle",
    Polygon = "polygon",
    Polyline = "polyline",
    Highlight = "highlight",
    Underline = "underline",
    Squiggly = "squiggly",
    Strikeout = "strikeout",
    Stamp = "stamp",
    Caret = "caret",
    Ink = "ink",
    Popup = "popup",
    FileAttachment = "fileattachment",
    Sound = "sound",
    Movie = "movie",
    Widget = "widget",
    Screen = "screen",
    PrinterMark = "printermark",
    TrapNet = "trapnet",
    Watermark = "watermark",
    ThreeD = "threed",
    RichMedia = "richmedia",
    XfaWidget = "xfawidget",
    Redacted = "redacted",
}

export type AnnotationAppearance = {
    color: string;
    opacity: number;
    border_width?: number;
}

export type AnnotationMetadata = {
    author?: string;
    contents?: string;
    creation_date?: string;
    modified_date?: string;
}

export type AnnotationFlags = {
    hidden: boolean;
    locked: boolean;
    printable: boolean;
    read_only: boolean;
}

export type Annotation = {
    id: string;
    page_index: number;
    subtype: AnnotationType;
    rect: PdfRect;
    geometry: AnnotationGeometry;
    appearance: AnnotationAppearance;
    metadata: AnnotationMetadata;
    flags: AnnotationFlags;
}
