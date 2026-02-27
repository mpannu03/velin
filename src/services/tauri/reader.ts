import { Bookmarks, PageText, PdfInfo } from "@/shared/types";
import { Annotation, RenderedPage, RenderedTile } from "@/screens/reader/types";
import { InvokeResult, safeInvoke } from "@/services/tauri";

export const openPdf = async (path: string): Promise<InvokeResult<string>> => {
  return safeInvoke<string>("open_pdf", { path });
};

export const renderPage = async (
  id: string,
  pageIndex: number,
  targetWidth: number,
): Promise<InvokeResult<RenderedPage>> => {
  const data = await safeInvoke<Uint8Array>("render_page", {
    id,
    pageIndex,
    targetWidth,
  });

  if (!data.ok) return { ok: false, error: data.error };

  let buffer = data.data;
  if (!(buffer instanceof Uint8Array)) {
    buffer = new Uint8Array(buffer as unknown as number[]);
  }

  const view = new DataView(
    buffer.buffer,
    buffer.byteOffset,
    buffer.byteLength,
  );
  const width = view.getUint32(0, false);
  const height = view.getUint32(4, false);
  const webpBytes = buffer.slice(8);

  // Fallback: Full page renders still use raw pixels for now
  // because multiple things (text layer, etc) depend on it.
  const blob = new Blob([webpBytes], { type: "image/webp" });
  const bitmap = await createImageBitmap(blob);
  const canvas = document.createElement("canvas");
  canvas.width = width;
  canvas.height = height;
  const ctx = canvas.getContext("2d")!;
  ctx.drawImage(bitmap, 0, 0);
  const imageData = ctx.getImageData(0, 0, width, height);
  bitmap.close();

  return {
    ok: true,
    data: {
      width,
      height,
      pixels: imageData.data,
    } as any,
  };
};

export const renderTile = async (
  id: string,
  pageIndex: number,
  targetWidth: number,
  tileX: number,
  tileY: number,
  tileWidth: number,
  tileHeight: number,
): Promise<InvokeResult<RenderedTile>> => {
  const data = await safeInvoke<Uint8Array>("render_tile", {
    id,
    pageIndex,
    targetWidth,
    tileX,
    tileY,
    tileWidth,
    tileHeight,
  });

  if (!data.ok) return { ok: false, error: data.error };

  let buffer = data.data;
  if (!(buffer instanceof Uint8Array)) {
    buffer = new Uint8Array(buffer as unknown as number[]);
  }

  const view = new DataView(
    buffer.buffer,
    buffer.byteOffset,
    buffer.byteLength,
  );
  const x = view.getInt32(0, false);
  const y = view.getInt32(4, false);
  const width = view.getInt32(8, false);
  const height = view.getInt32(12, false);
  const webpBytes = buffer.slice(16);

  // Tiles: Use ImageBitmap for direct GPU upload
  const blob = new Blob([webpBytes], { type: "image/webp" });
  const bitmap = await createImageBitmap(blob);

  return {
    ok: true,
    data: {
      x,
      y,
      width,
      height,
      pixels: bitmap as any,
    } as any,
  };
};

export const closePdf = async (id: string): Promise<InvokeResult<void>> => {
  return safeInvoke("close_pdf", { id });
};

export const fetchPdfInfo = async (
  id: string,
): Promise<InvokeResult<PdfInfo>> => {
  return safeInvoke<PdfInfo>("get_pdf_info", { id });
};

export const fetchBookmarks = async (
  id: string,
): Promise<InvokeResult<Bookmarks>> => {
  return safeInvoke<Bookmarks>("get_bookmarks", { id });
};

export const fetchTextByPage = async (
  id: string,
  pageIndex: number,
): Promise<InvokeResult<PageText>> => {
  return safeInvoke<PageText>("get_text_by_page", { id, pageIndex });
};

export const generatePreview = async (
  id: string,
): Promise<InvokeResult<Uint8Array>> => {
  return safeInvoke<Uint8Array>("generate_preview", { id });
};

export const fetchAnnotations = async (
  id: string,
): Promise<InvokeResult<Annotation[]>> => {
  return safeInvoke<Annotation[]>("get_annotations", { id });
};
