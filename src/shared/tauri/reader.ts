import { Bookmarks, PdfInfo } from '../types';
import { RenderedPage } from '@/screens/reader/types';
import { InvokeResult, safeInvoke } from './invoke_result';

export const openPdf = async (
  path: string
): Promise<InvokeResult<string>> => {
  return safeInvoke<string>('open_pdf', { path });
};

export const renderPage = async (
  id: string,
  pageIndex: number,
  targetWidth: number
): Promise<InvokeResult<RenderedPage>> => {
  const data = await safeInvoke<Uint8Array>('render_page', {
    id,
    pageIndex,
    targetWidth,
  });

  if (!data.ok) return { ok: false, error: data.error };

  let buffer = data.data;
  if (!(buffer instanceof Uint8Array)) {
    buffer = new Uint8Array(buffer as unknown as number[]);
  }

  const view = new DataView(buffer.buffer);
  const width = view.getUint32(0, false);
  const height = view.getUint32(4, false);
  const pixels = buffer.slice(8);

  return {
    ok: true,
    data: {
      width,
      height,
      pixels: new Uint8ClampedArray(pixels)
    } as any
  };
};

export const closePdf = async (
  id: string
): Promise<InvokeResult<void>> => {
  return safeInvoke('close_pdf', { id });
};

export const fetchPdfInfo = async (
  id: string
): Promise<InvokeResult<PdfInfo>> => {
  return safeInvoke<PdfInfo>('get_pdf_info', { id });
}

export const fetchBookmarks = async (
  id: string
): Promise<InvokeResult<Bookmarks>> => {
  return safeInvoke<Bookmarks>('get_bookmarks', { id });
}