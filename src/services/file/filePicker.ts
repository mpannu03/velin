import { open, save } from "@tauri-apps/plugin-dialog";

export async function pickPdfFile(): Promise<string | null> {
  const file = await open({
    multiple: false,
    directory: false,
    filters: [{ name: "PDF", extensions: ["pdf"] }],
  });

  return file as string | null;
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
