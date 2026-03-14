import { open, save } from "@tauri-apps/plugin-dialog";

export async function pickPdfFile(multiple: false): Promise<string | null>;
export async function pickPdfFile(multiple: true): Promise<string[] | null>;
export async function pickPdfFile(
  multiple: boolean = false,
): Promise<string | string[] | null> {
  const file = await open({
    multiple,
    directory: false,
    filters: [{ name: "PDF", extensions: ["pdf"] }],
  });

  return file;
}

export async function savePdfFile(
  defaultPath?: string,
): Promise<string | null> {
  const path = await save({
    filters: [{ name: "PDF", extensions: ["pdf"] }],
    defaultPath,
  });

  return path;
}

export async function pickDirectory(): Promise<string | null> {
  const directory = await open({
    multiple: false,
    directory: true,
  });

  return directory;
}
