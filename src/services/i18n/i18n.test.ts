import { describe, it, expect, afterEach, beforeEach } from "vitest";
import i18n from "./i18n"; // Import our configured instance
import { DEFAULT_LANGUAGE } from "./languages";

describe("i18n service", () => {
  const originalLanguage = navigator.language;

  beforeEach(async () => {
    if (!i18n.isInitialized) {
      await i18n.init();
    }
  });

  afterEach(() => {
    Object.defineProperty(navigator, "language", {
      value: originalLanguage,
      configurable: true,
    });
  });

  it("should have a default language configured", () => {
    expect(DEFAULT_LANGUAGE).toBe("en");
  });

  it("should be initialized", () => {
    expect(i18n.isInitialized).toBe(true);
  });

  it("should have the correct fallback language", () => {
    expect(i18n.options.fallbackLng).toContain(DEFAULT_LANGUAGE);
  });

  it("should have namespaces configured", () => {
    const ns = i18n.options.ns as string[];
    expect(ns).toContain("common");
    expect(ns).toContain("home");
    expect(ns).toContain("reader");
  });

  it("should have interpolation configured", () => {
    expect(i18n.options.interpolation?.escapeValue).toBe(false);
  });
});
