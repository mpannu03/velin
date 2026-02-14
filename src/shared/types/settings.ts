import { MantineColorScheme } from "@mantine/core";

export interface AppearanceSettings {
  colorScheme: MantineColorScheme;
  color: string;
} 

export interface ReaderSettings {
  defaultZoom: number;
  defaultViewMode: 'single' | 'continuous' | 'double';
  scrollSensitivity: number;
}

export interface GeneralSettings {
  checkUpdateOnStart: boolean;
  language: string;
}

export interface Settings {
  appearance: AppearanceSettings;
  reader: ReaderSettings;
  general: GeneralSettings;
}

export const DEFAULT_SETTINGS: Settings = {
  appearance: {
    colorScheme: "auto",
    color: 'red',
  },
  reader: {
    defaultZoom: 1.0,
    defaultViewMode: 'continuous',
    scrollSensitivity: 1.0,
  },
  general: {
    checkUpdateOnStart: true,
    language: 'en',
  },
};
