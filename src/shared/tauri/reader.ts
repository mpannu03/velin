import { PdfInfo } from '../types';
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
  // We use standard invoke. If the Rust command returns tauri::ipc::Response,
  // the invoke promise resolves to the body.
  // BUT: tauri-v2 invoke might default to JSON parsing.
  // If it fails to parse JSON, it might throw or return text?
  // Let's rely on standard current behavior: invoke returns deserialized JSON.
  // Problem: We are sending raw bytes. response.body is Vec<u8>.
  // If we return Response::new(data), the client receives the bytes.
  // However, safeInvoke wrapper currently expects generics compatible with the response.
  // We need to act as if it returns Uint8Array (or Array<number> if it gets serialized).
  // Actually, for binary optimization to work, we must ensure invoke doesn't parse it as JSON array.
  // Tauri v2 `invoke` does NOT automatically support `Response` object return in the same way.
  // WAIT: The efficient way is for invoke to return Uint8Array.
  // If we use Response, we might need a custom fetch.
  // Let's assume standard invoke for now, but handle the binary unpacking.
  // If `invoke` returns the raw buffer (ArrayBuffer/Uint8Array), we are good.

  try {
    const data = await safeInvoke<Uint8Array>('render_page', {
      id,
      pageIndex,
      targetWidth,
    });

    // safeInvoke wrapper might try to verify specific structure?
    // Let's look at safeInvoke. If it just returns T, we cast it.

    // @ts-ignore: safeInvoke returns InvokeResult which wraps result/error.
    // If successful, data.data should be the Uint8Array.

    if (!data.ok) return { ok: false, error: data.error };

    let buffer = data.data;
    if (!(buffer instanceof Uint8Array)) {
      buffer = new Uint8Array(buffer as unknown as number[]);
    }
    // buffer is Uint8Array (or Array<number> if serialized as JSON array - we hope NOT).
    // If it *is* an array of numbers (JSON), optimization failed.
    // If we used tauri::ipc::Response, it SHOULD be efficient binary.

    // Manual deserialization of [width(4)][height(4)][pixels...]
    const view = new DataView(buffer.buffer);
    const width = view.getUint32(0, false); // Big Endian
    const height = view.getUint32(4, false); // Big Endian
    const pixels = buffer.slice(8);

    return {
      ok: true,
      data: {
        width,
        height,
        pixels: new Uint8ClampedArray(pixels)
        // The RenderedPage type expects number[] or Uint8ClampedArray.
        // We use Uint8ClampedArray for efficiency.
      } as any
    };
  } catch (e: any) {
    return { ok: false, error: e.toString() };
  }
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