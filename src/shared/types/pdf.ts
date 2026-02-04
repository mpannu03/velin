// Core document type (Rust-aligned)
export type PdfDocument = {
  id: string;
  filePath: string;
  title: string;
};

// UI viewer state (frontend-only)
export type PdfViewerState = {
  documentId: string;

  page: number;
  zoom: number;
  scrollTop: number;

  viewMode: 'single' | 'continuous';
};

// Render identity
export type RenderKey = {
  documentId: string;
  pageIndex: number;
  scale: number;
};

export type PdfInfo = {
  page_count: number;
  width: number;
  height: number;
}

export type Bookmark = {
  title: string;
  page_index: number | null;
  children: Bookmark[];
}

export type Bookmarks = {
  items: Bookmark[];
};

/* ---------- factories ---------- */

export const createPdfDocument = (
  overrides?: Partial<PdfDocument>
): PdfDocument => ({
  id: '',
  filePath: '',
  title: '',
  ...overrides,
});

export const createPdfViewerState = (
  documentId: string,
  overrides?: Partial<PdfViewerState>
): PdfViewerState => ({
  documentId,
  page: 1,
  zoom: 1.0,
  scrollTop: 0,
  viewMode: 'continuous',
  ...overrides,
});

/* ---------- helpers ---------- */

export const renderKeyToString = (key: RenderKey) =>
  `${key.documentId}:${key.pageIndex}:${key.scale}`;
