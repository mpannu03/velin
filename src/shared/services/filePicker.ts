import { open } from "@tauri-apps/plugin-dialog";

export async function pickPdfFile(): Promise<string | null> {
  const file = await open({
    multiple: false,
    directory: false,
    filters: [
      { name: "PDF", extensions: ["pdf"] }
    ],
  });

  return file;
}
