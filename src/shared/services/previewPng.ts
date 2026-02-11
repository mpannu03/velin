import { appCacheDir, join } from "@tauri-apps/api/path";
import { generatePreview } from "../tauri";
import { PdfDocument } from "../types";

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

export async function getPreview(
  documentId: string
): Promise<string | undefined> {
  // This might be used elsewhere, but for now we follow the same pattern
  const appCache = await appCacheDir();
  const previewPath = await join(appCache, 'previews', `${documentId}.png`);
  
  return previewPath;
}