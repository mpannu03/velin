import { create } from "zustand";
import { Settings, DEFAULT_SETTINGS } from "@/shared/types";
import { settingsStore } from "@/services/storage/store";
import i18next from "@/services/i18n/i18n";

interface SettingsState {
  settings: Settings;
  init: () => Promise<void>;
  updateSettings: (
    patch: Partial<Settings> | ((prev: Settings) => Settings),
  ) => Promise<void>;
  updateAppearance: (patch: Partial<Settings["appearance"]>) => Promise<void>;
  updateReader: (patch: Partial<Settings["reader"]>) => Promise<void>;
  updateGeneral: (patch: Partial<Settings["general"]>) => Promise<void>;
  restoreDefaults: () => Promise<void>;
}

export const useSettingsStore = create<SettingsState>((set, get) => ({
  settings: DEFAULT_SETTINGS,

  init: async () => {
    const savedSettings = await settingsStore.get<Settings>("settings");
    if (savedSettings) {
      set({ settings: { ...DEFAULT_SETTINGS, ...savedSettings } });
    }
  },

  updateSettings: async (patch) => {
    const current = get().settings;
    const nextSettings =
      typeof patch === "function" ? patch(current) : { ...current, ...patch };

    set({ settings: nextSettings });
    await settingsStore.set("settings", nextSettings);
    await settingsStore.save();
  },

  updateAppearance: async (patch) => {
    const current = get().settings;
    const nextSettings = {
      ...current,
      appearance: { ...current.appearance, ...patch },
    };
    set({ settings: nextSettings });
    await settingsStore.set("settings", nextSettings);
    await settingsStore.save();
  },

  updateReader: async (patch) => {
    const current = get().settings;
    const nextSettings = {
      ...current,
      reader: { ...current.reader, ...patch },
    };
    set({ settings: nextSettings });
    await settingsStore.set("settings", nextSettings);
    await settingsStore.save();
  },

  updateGeneral: async (patch) => {
    const current = get().settings;
    const nextSettings = {
      ...current,
      general: { ...current.general, ...patch },
    };
    i18next.changeLanguage(nextSettings.general.language);
    set({ settings: nextSettings });
    await settingsStore.set("settings", nextSettings);
    await settingsStore.save();
  },

  restoreDefaults: async () => {
    i18next.changeLanguage(DEFAULT_SETTINGS.general.language);
    set({ settings: DEFAULT_SETTINGS });
    await settingsStore.set("settings", DEFAULT_SETTINGS);
    await settingsStore.save();
  },
}));
