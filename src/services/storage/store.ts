import { load } from "@tauri-apps/plugin-store";

export const documentStore = await load("documents.json");
export const settingsStore = await load("settings.json");