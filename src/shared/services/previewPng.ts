import { appCacheDir, join } from "@tauri-apps/api/path";
import { generatePreview } from "../tauri";
import { DocumentMeta, PdfDocument } from "../types";
import { remove, BaseDirectory } from '@tauri-apps/plugin-fs';

export async function savePreview(
  document: PdfDocument
): Promise<string> {
  const appCache = await appCacheDir();
  const previewPath = await join(appCache, 'previews', `${document.id}.png`);

  const data = await generatePreview(document.id);

  if (!data.ok) {
    console.error(data.error);
    throw new Error(data.error);
  }

  return previewPath;
}

export async function deletePreview(
  document: DocumentMeta
): Promise<void> {
  if (!document.previewPath) {
    return;
  }

  try {
    await remove(document.previewPath, {
      baseDir: BaseDirectory.AppCache
    })
  } catch(error) {
    console.error(error);
  }
}