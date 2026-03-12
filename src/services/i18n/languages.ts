export const LANGUAGES = {
  en: "English",
} as const;

export type LanguageCode = keyof typeof LANGUAGES;

export const DEFAULT_LANGUAGE: LanguageCode = "en";
