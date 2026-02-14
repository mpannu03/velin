import { appDataDir, BaseDirectory, join } from "@tauri-apps/api/path";
import { exists, mkdir, remove, writeFile } from "@tauri-apps/plugin-fs";
import { fetch } from '@tauri-apps/plugin-http';
import { safeInvoke } from "@/services/tauri";

const WORDNET_URL = "https://wordnetcode.princeton.edu/3.0/WNdb-3.0.tar.gz";

export type WordnetInstallStatus =
  | { stage: "downloading"; percent: number }
  | { stage: "extracting" }
  | { stage: "completed" };

async function getWordnetDatabasePath(): Promise<string> {
  const base = await appDataDir();
  return await join(base, "wordnet", "WNdb-3.0");
}

async function getDictPath(): Promise<string> {
  const base = await getWordnetDatabasePath();
  return await join(base, "dict");
}

export async function isDictionaryInstalled(): Promise<boolean> {
  const path = await getDictPath();
  return await exists(path);
}

export async function downloadAndInstallWordNet(
  onStatus?: (status: WordnetInstallStatus) => void
): Promise<void> {
  const basePath = await getWordnetDatabasePath();
  const dictPath = await getDictPath();

  if (await exists(dictPath)) {
    onStatus?.({ stage: "completed" });
    return;
  }

  await mkdir(basePath, {
    recursive: true,
    baseDir: BaseDirectory.AppData,
  })

  const response = await fetch(WORDNET_URL);

  if (!response.ok) {
    throw new Error('Failed to download WordNet database');
  }

  const contentLength = Number(response.headers.get("content-length")) || 0;
  const reader = response.body?.getReader();

  if (!reader) {
    throw new Error("Failed to read response body");
  }

  let received = 0;
  const chunks: Uint8Array[] = [];

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;

    if (value) {
      chunks.push(value);
      received += value.length;

      if (contentLength) {
        const percent = Math.round((received / contentLength) * 100);
        onStatus?.({ stage: "downloading", percent });
      }
    }
  }

  const buffer = new Uint8Array(received);
  let offset = 0;
  for (const chunk of chunks) {
    buffer.set(chunk, offset);
    offset += chunk.length;
  }

  const tarPath = await join(basePath, "WNdb-3.0.tar.gz");

  await writeFile(tarPath, buffer, {
    baseDir: BaseDirectory.AppData,
  });

  onStatus?.({ stage: "extracting" });

  const extractResult = await safeInvoke('extract_tar_gz', {
    path: tarPath,
    dest: basePath,
  });

  if (!extractResult.ok) {
    throw new Error(`Extraction failed: ${extractResult.error}`);
  }

  await remove(tarPath);

  const installed = await exists(dictPath);

  if (!installed) {
    throw new Error('WordNet extraction failed: dict folder not found');
  }

  onStatus?.({ stage: "completed" });
}