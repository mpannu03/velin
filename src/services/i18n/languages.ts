export const LANGUAGES = {
  en: "English",
  hi: "हिन्दी",
} as const;

export type LanguageCode = keyof typeof LANGUAGES;

export const DEFAULT_LANGUAGE: LanguageCode = "en";
