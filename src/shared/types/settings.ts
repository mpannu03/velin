export type Theme = 'light' | 'dark' | 'system';

export interface AppearanceSettings {
  theme: Theme;
  accentColor: string;
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
    theme: 'system',
    accentColor: 'velinColor',
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
