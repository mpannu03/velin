import { describe, it, expect, vi } from "vitest";
import {
  mergePdfs,
  splitPdf,
  extractPdf,
  pdfToImg,
  compressPdf,
} from "./tools";
import { safeInvoke } from "./invokeResult";
import { PageSelectionInput } from "@/pdf/tools";

// Mock safeInvoke
vi.mock("./invokeResult", () => ({
  safeInvoke: vi.fn(),
}));

describe("tools service", () => {
  const mockPageSelectionInput: PageSelectionInput = {
    file: "/path/to/pdf",
    selection: "all",
  };

  describe("mergePdfs", () => {
    it("should call safeInvoke with correct arguments", async () => {
      const inputs = [mockPageSelectionInput];
      const dest = "/path/to/dest.pdf";
      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: undefined });

      await mergePdfs(inputs, dest);

      expect(safeInvoke).toHaveBeenCalledWith("merge_pdfs", {
        rawInputs: inputs,
        dest,
      });
    });
  });

  describe("splitPdf", () => {
    it("should call safeInvoke with correct arguments", async () => {
      const destDir = "/path/to/dir";
      const fileName = "split";
      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: undefined });

      await splitPdf(mockPageSelectionInput, destDir, fileName);

      expect(safeInvoke).toHaveBeenCalledWith("split_pdf", {
        rawInput: mockPageSelectionInput,
        destDir,
        fileName,
      });
    });
  });

  describe("extractPdf", () => {
    it("should call safeInvoke with correct arguments", async () => {
      const dest = "/path/to/extract.pdf";
      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: undefined });

      await extractPdf(mockPageSelectionInput, dest);

      expect(safeInvoke).toHaveBeenCalledWith("extract_pdf", {
        rawInput: mockPageSelectionInput,
        dest,
      });
    });
  });

  describe("pdfToImg", () => {
    it("should call safeInvoke with correct arguments", async () => {
      const destDir = "/path/to/img/dir";
      const options = {
        format: "png",
        dpi: 300,
        quality: 100,
        mode: "single",
        pattern: "page_{page}",
      };
      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: undefined });

      await pdfToImg(mockPageSelectionInput, destDir, options);

      expect(safeInvoke).toHaveBeenCalledWith("pdf_to_image", {
        rawInput: mockPageSelectionInput,
        destDir,
        options,
      });
    });
  });

  describe("compressPdf", () => {
    it("should call safeInvoke with correct arguments", async () => {
      const inputPath = "/path/to/input.pdf";
      const outputPath = "/path/to/output.pdf";
      const quality = 75;
      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: undefined });

      await compressPdf(inputPath, outputPath, quality);

      expect(safeInvoke).toHaveBeenCalledWith("compress_pdf", {
        inputPath,
        outputPath,
        quality,
      });
    });
  });
});
