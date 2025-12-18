export type PdfDocument = {
  filePath: string;
  title: string;
  page: number;
  zoom: number;
  scrollTop: number;
};

export const createPdfDocument = (overrides?: Partial<PdfDocument>): PdfDocument => ({
  filePath: '',
  title: '',
  page: 1,
  zoom: 1.0,
  scrollTop: 0,
  ...overrides,
});