import { describe, it, expect, vi, beforeEach } from "vitest";
import {
  openPdf,
  getPageCount,
  renderPage,
  renderTile,
  closePdf,
  fetchPdfInfo,
  fetchBookmarks,
  fetchTextByPage,
  generatePreview,
  fetchAnnotations,
} from "./reader";
import { safeInvoke } from "@/services/tauri";

// Mock safeInvoke
vi.mock("@/services/tauri", () => ({
  safeInvoke: vi.fn(),
}));

describe("reader tauri service", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("openPdf", () => {
    it("should call safeInvoke with correct arguments", async () => {
      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: "doc-id" });
      const result = await openPdf("/path/to.pdf");
      expect(safeInvoke).toHaveBeenCalledWith("open_pdf", {
        path: "/path/to.pdf",
      });
      expect(result).toEqual({ ok: true, data: "doc-id" });
    });
  });

  describe("getPageCount", () => {
    it("should call safeInvoke with correct arguments", async () => {
      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: 10 });
      const result = await getPageCount("doc-id");
      expect(safeInvoke).toHaveBeenCalledWith("get_page_count", {
        file: "doc-id",
      });
      expect(result).toEqual({ ok: true, data: 10 });
    });
  });

  describe("renderPage", () => {
    it("should process binary buffer and return RenderedPage on success", async () => {
      const width = 100;
      const height = 200;
      const buffer = new Uint8Array(8 + 10);
      const view = new DataView(buffer.buffer);
      view.setUint32(0, width, false);
      view.setUint32(4, height, false);

      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: buffer });

      const result = await renderPage("doc-id", 0, 1000);

      expect(safeInvoke).toHaveBeenCalledWith("render_page", {
        id: "doc-id",
        pageIndex: 0,
        targetWidth: 1000,
      });
      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.data.width).toBe(width);
        expect(result.data.height).toBe(height);
        expect(result.data.pixels).toBeInstanceOf(Uint8ClampedArray);
      }
    });

    it("should handle raw array data and convert to Uint8Array (edge case)", async () => {
      const width = 20;
      const height = 20;
      const buffer = new Uint8Array(8 + 4);
      const view = new DataView(buffer.buffer);
      view.setUint32(0, width, false);
      view.setUint32(4, height, false);
      const dataArr = Array.from(buffer);

      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: dataArr });

      const result = await renderPage("doc-id", 0, 800);
      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.data.width).toBe(width);
        expect(result.data.height).toBe(height);
      }
    });

    it("should return error if safeInvoke fails", async () => {
      vi.mocked(safeInvoke).mockResolvedValue({
        ok: false,
        error: "Render error",
      });
      const result = await renderPage("doc-id", 0, 1000);
      expect(result).toEqual({ ok: false, error: "Render error" });
    });
  });

  describe("renderTile", () => {
    it("should process binary buffer and return RenderedTile on success", async () => {
      const x = 10,
        y = 20,
        w = 100,
        h = 100;
      const buffer = new Uint8Array(16 + 10);
      const view = new DataView(buffer.buffer);
      view.setInt32(0, x, false);
      view.setInt32(4, y, false);
      view.setInt32(8, w, false);
      view.setInt32(12, h, false);

      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: buffer });

      const result = await renderTile("doc-id", 0, 1000, x, y, w, h);

      expect(safeInvoke).toHaveBeenCalledWith("render_tile", {
        id: "doc-id",
        pageIndex: 0,
        targetWidth: 1000,
        tileX: x,
        tileY: y,
        tileWidth: w,
        tileHeight: h,
      });
      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.data.x).toBe(x);
        expect(result.data.y).toBe(y);
        // pixels should be the mock ImageBitmap (which is a canvas in setup.ts)
        expect(result.data.pixels).toBeDefined();
      }
    });
  });

  describe("simple safeInvoke wrappers", () => {
    it("closePdf should call safeInvoke", async () => {
      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: undefined });
      await closePdf("doc-id");
      expect(safeInvoke).toHaveBeenCalledWith("close_pdf", { id: "doc-id" });
    });

    it("fetchPdfInfo should call safeInvoke", async () => {
      const mockInfo = { page_count: 10 };
      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: mockInfo });
      const result = await fetchPdfInfo("doc-id");
      expect(result).toEqual({ ok: true, data: mockInfo });
    });

    it("fetchBookmarks should call safeInvoke", async () => {
      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: [] });
      await fetchBookmarks("doc-id");
      expect(safeInvoke).toHaveBeenCalledWith("get_bookmarks", {
        id: "doc-id",
      });
    });

    it("fetchTextByPage should call safeInvoke", async () => {
      vi.mocked(safeInvoke).mockResolvedValue({
        ok: true,
        data: { text: "", char_rects: [] },
      });
      await fetchTextByPage("doc-id", 5);
      expect(safeInvoke).toHaveBeenCalledWith("get_text_by_page", {
        id: "doc-id",
        pageIndex: 5,
      });
    });

    it("generatePreview should call safeInvoke", async () => {
      vi.mocked(safeInvoke).mockResolvedValue({
        ok: true,
        data: new Uint8Array(),
      });
      await generatePreview("doc-id");
      expect(safeInvoke).toHaveBeenCalledWith("generate_preview", {
        id: "doc-id",
      });
    });

    it("fetchAnnotations should call safeInvoke", async () => {
      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: [] });
      await fetchAnnotations("doc-id");
      expect(safeInvoke).toHaveBeenCalledWith("get_annotations", {
        id: "doc-id",
      });
    });
  });
});
