import { describe, it, expect, vi, beforeEach } from "vitest";
import { pickPdfFile, savePdfFile, pickDirectory } from "./filePicker";
import { open, save } from "@tauri-apps/plugin-dialog";

// Mock Tauri dialog plugin
vi.mock("@tauri-apps/plugin-dialog", () => ({
  open: vi.fn(),
  save: vi.fn(),
}));

describe("filePicker service", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("pickPdfFile", () => {
    it("should call open with correct parameters for single file selection", async () => {
      vi.mocked(open).mockResolvedValue("/path/to/file.pdf");

      const result = await pickPdfFile(false);

      expect(open).toHaveBeenCalledWith({
        multiple: false,
        directory: false,
        filters: [{ name: "PDF", extensions: ["pdf"] }],
      });
      expect(result).toBe("/path/to/file.pdf");
    });

    it("should call open with correct parameters for multiple file selection", async () => {
      const paths = ["/path/to/file1.pdf", "/path/to/file2.pdf"];
      vi.mocked(open).mockResolvedValue(paths);

      const result = await pickPdfFile(true);

      expect(open).toHaveBeenCalledWith({
        multiple: true,
        directory: false,
        filters: [{ name: "PDF", extensions: ["pdf"] }],
      });
      expect(result).toEqual(paths);
    });

    it("should return null if selection is cancelled", async () => {
      vi.mocked(open).mockResolvedValue(null);

      const result = await pickPdfFile(false);

      expect(result).toBe(null);
    });
  });

  describe("savePdfFile", () => {
    it("should call save with correct parameters", async () => {
      vi.mocked(save).mockResolvedValue("/path/to/save.pdf");
      const defaultPath = "/default/path/file.pdf";

      const result = await savePdfFile(defaultPath);

      expect(save).toHaveBeenCalledWith({
        filters: [{ name: "PDF", extensions: ["pdf"] }],
        defaultPath,
      });
      expect(result).toBe("/path/to/save.pdf");
    });

    it("should return null if save is cancelled", async () => {
      vi.mocked(save).mockResolvedValue(null);

      const result = await savePdfFile();

      expect(result).toBe(null);
    });
  });

  describe("pickDirectory", () => {
    it("should call open with correct parameters for directory selection", async () => {
      vi.mocked(open).mockResolvedValue("/path/to/dir");

      const result = await pickDirectory();

      expect(open).toHaveBeenCalledWith({
        multiple: false,
        directory: true,
      });
      expect(result).toBe("/path/to/dir");
    });

    it("should return null if directory selection is cancelled", async () => {
      vi.mocked(open).mockResolvedValue(null);

      const result = await pickDirectory();

      expect(result).toBe(null);
    });
  });
});
