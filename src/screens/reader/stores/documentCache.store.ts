import { create } from "zustand";
import { Annotation, RenderedPage, RenderedTile } from "../types";
import { PdfInfo, PageText, Bookmark } from "@/shared/types";
import {
  fetchAnnotations,
  fetchBookmarks,
  fetchPdfInfo,
  fetchTextByPage,
} from "@/services/tauri";

const MAX_CACHE_MB = 512;
const MAX_TEXT_CACHE_PAGES = 100;

type Result<T> = { ok: true; data: T } | { ok: false; error: string };

// Document-level cache containing all related data
type DocumentCache = {
  // Metadata about the PDF
  info?: PdfInfo;

  // Rendered pages (keyed by resolution: "width x height")
  pages: Record<string, RenderedPage>;

  // Rendered tiles (keyed by resolution and position: "targetWidth:x_y_wxh")
  tiles: Record<string, RenderedTile>;

  // Text data (keyed by page number)
  text: Record<number, PageText>;

  // Annotations data (keyed by page number)
  annotations: Annotation[];

  // Bookmarks data
  bookmarks: Bookmark[];

  // Statistics
  lastAccessed: number;
  memoryMb: number;
};

type DocumentCacheState = {
  // Cache per document ID
  documents: Record<string, DocumentCache>;

  // Global memory tracking
  totalMemoryMb: number;
  maxMemoryMb: number;

  // Page operations
  addPage: (id: string, pageIndex: number, page: RenderedPage) => void;
  getPage: (
    id: string,
    pageIndex: number,
    width: number,
  ) => RenderedPage | undefined;
  getAnyPage: (id: string, pageIndex: number) => RenderedPage | undefined;

  // Tile operations
  addTile: (
    id: string,
    pageIndex: number,
    targetWidth: number,
    tile: RenderedTile,
  ) => void;
  getTile: (
    id: string,
    pageIndex: number,
    targetWidth: number,
    x: number,
    y: number,
    width: number,
    height: number,
  ) => RenderedTile | undefined;

  // Text operations
  addText: (id: string, pageIndex: number, text: PageText) => void;
  getText: (id: string, pageIndex: number) => PageText | undefined;
  fetchText: (id: string, pageIndex: number) => Promise<void>;

  // Bookmarks operations
  getBookmarks: (id: string) => Bookmark[] | undefined;
  fetchBookmarks: (id: string) => Promise<Result<Bookmark[]>>;

  // Annotations operations
  getAnnotations: (id: string) => Annotation[] | undefined;
  fetchAnnotations: (id: string) => Promise<Result<Annotation[]>>;

  // Info operations
  setInfo: (id: string, info: PdfInfo) => void;
  getInfo: (id: string) => PdfInfo | undefined;
  fetchInfo: (id: string) => Promise<void>;

  // Cleanup operations
  purgeDocument: (id: string) => void;
  clear: () => void;
};

function estimatePageMB(page: RenderedPage): number {
  if (page.pixels && page.pixels.length > 0) {
    return page.pixels.length / (1024 * 1024);
  }
  return (page.width * page.height * 4) / (1024 * 1024);
}

function estimateTileMB(tile: RenderedTile): number {
  if (tile.pixels instanceof ImageBitmap) {
    // ImageBitmap is on GPU. Conservative estimate: 2 bytes per pixel
    return (tile.width * tile.height * 2) / (1024 * 1024);
  }

  if (tile.pixels && (tile.pixels as any).length > 0) {
    return (tile.pixels as any).length / (1024 * 1024);
  }
  return (tile.width * tile.height * 4) / (1024 * 1024);
}

function estimateTextMB(_text: PageText): number {
  return 0.01;
}

function getOrCreateDocCache(
  documents: Record<string, DocumentCache>,
  id: string,
): DocumentCache {
  if (!documents[id]) {
    const newCache: DocumentCache = {
      pages: {},
      tiles: {},
      text: {},
      annotations: [],
      bookmarks: [],
      lastAccessed: Date.now(),
      memoryMb: 0,
    };
    documents[id] = newCache;
  }

  const cache = documents[id]!;
  cache.lastAccessed = Date.now();
  return cache;
}

export const useDocumentCacheStore = create<DocumentCacheState>((set, get) => ({
  documents: {},
  totalMemoryMb: 0,
  maxMemoryMb: MAX_CACHE_MB,

  addPage: (id: string, pageIndex: number, page: RenderedPage) => {
    set((state) => {
      const newDocuments = { ...state.documents };
      const docCache = getOrCreateDocCache(newDocuments, id);

      const key = `${pageIndex}:${page.width}x${page.height}`;
      const pageMb = estimatePageMB(page);

      const existingPage = docCache.pages[key];
      if (existingPage) {
        const oldMb = estimatePageMB(existingPage);
        docCache.memoryMb -= oldMb;
      }

      docCache.pages[key] = page;
      docCache.memoryMb += pageMb;

      let totalMemoryMb = 0;
      for (const cache of Object.values(newDocuments)) {
        totalMemoryMb += cache.memoryMb;
      }

      while (
        totalMemoryMb > MAX_CACHE_MB &&
        Object.keys(newDocuments).length > 0
      ) {
        let oldestId: string | undefined;
        let oldestTime = Infinity;

        for (const [docId, cache] of Object.entries(newDocuments)) {
          if (cache.lastAccessed < oldestTime) {
            oldestTime = cache.lastAccessed;
            oldestId = docId;
          }
        }

        if (oldestId) {
          const removedCache = newDocuments[oldestId];
          if (removedCache) {
            totalMemoryMb -= removedCache.memoryMb;
          }
          delete newDocuments[oldestId];
        } else {
          break;
        }
      }

      return { documents: newDocuments, totalMemoryMb };
    });
  },

  getPage: (id, pageIndex, width) => {
    const docCache = get().documents[id];
    if (!docCache) return undefined;

    docCache.lastAccessed = Date.now();

    for (const key in docCache.pages) {
      const page = docCache.pages[key];

      if (key.startsWith(`${pageIndex}:`) && Math.abs(page.width - width) < 1) {
        return page;
      }
    }

    return undefined;
  },

  getAnyPage: (id, pageIndex) => {
    const docCache = get().documents[id];
    if (!docCache || Object.keys(docCache.pages).length === 0) return undefined;

    docCache.lastAccessed = Date.now();

    for (const key in docCache.pages) {
      const page = docCache.pages[key];

      if (key.startsWith(`${pageIndex}:`)) {
        return page;
      }
    }

    return undefined;
  },

  addTile: (id, pageIndex, targetWidth, tile) => {
    set((state) => {
      const newDocuments = { ...state.documents };
      const docCache = getOrCreateDocCache(newDocuments, id);

      const key = `${pageIndex}:${targetWidth}:${tile.x}_${tile.y}_${tile.width}x${tile.height}`;
      const tileMb = estimateTileMB(tile);

      const existingTile = docCache.tiles[key];
      if (existingTile) {
        const oldMb = estimateTileMB(existingTile);
        docCache.memoryMb -= oldMb;
      }

      docCache.tiles[key] = tile;
      docCache.memoryMb += tileMb;

      let totalMemoryMb = 0;
      for (const cache of Object.values(newDocuments)) {
        totalMemoryMb += cache.memoryMb;
      }

      // Memory pressure cleanup
      while (
        totalMemoryMb > MAX_CACHE_MB &&
        Object.keys(newDocuments).length > 0
      ) {
        let oldestId: string | undefined;
        let oldestTime = Infinity;

        for (const [docId, cache] of Object.entries(newDocuments)) {
          if (cache.lastAccessed < oldestTime) {
            oldestTime = cache.lastAccessed;
            oldestId = docId;
          }
        }

        if (oldestId) {
          const removedCache = newDocuments[oldestId];
          if (removedCache) {
            totalMemoryMb -= removedCache.memoryMb;
          }
          delete newDocuments[oldestId];
        } else {
          break;
        }
      }

      return { documents: newDocuments, totalMemoryMb };
    });
  },

  getTile: (id, pageIndex, targetWidth, x, y, width, height) => {
    const docCache = get().documents[id];
    if (!docCache) return undefined;

    docCache.lastAccessed = Date.now();
    const key = `${pageIndex}:${targetWidth}:${x}_${y}_${width}x${height}`;
    return docCache.tiles[key];
  },

  addText: (id, pageIndex, text) => {
    set((state) => {
      const newDocuments = { ...state.documents };
      const docCache = getOrCreateDocCache(newDocuments, id);

      const textMb = estimateTextMB(text);

      if (pageIndex in docCache.text) {
        docCache.memoryMb -= estimateTextMB(docCache.text[pageIndex]);
      }

      docCache.text[pageIndex] = text;
      docCache.memoryMb += textMb;

      const keys = Object.keys(docCache.text);
      if (keys.length > MAX_TEXT_CACHE_PAGES) {
        const oldestKey = Number(keys[0]);
        const oldestText = docCache.text[oldestKey];

        delete docCache.text[oldestKey];
        docCache.memoryMb -= estimateTextMB(oldestText);
      }

      let totalMemoryMb = 0;
      for (const cache of Object.values(newDocuments)) {
        totalMemoryMb += cache.memoryMb;
      }

      return { documents: newDocuments, totalMemoryMb };
    });
  },

  getText: (id, pageIndex) => {
    const docCache = get().documents[id];
    if (!docCache) return undefined;

    docCache.lastAccessed = Date.now();
    return docCache.text[pageIndex];
  },

  fetchText: async (id, pageIndex) => {
    const { getText, addText } = get();

    if (getText(id, pageIndex)) return;

    try {
      const result = await fetchTextByPage(id, pageIndex);

      if (result.ok) {
        addText(id, pageIndex, result.data);
      } else {
        console.error("Failed to fetch text:", result.error);
      }
    } catch (error) {
      console.error("Error fetching text:", error);
    }
  },

  getBookmarks: (id: string): Bookmark[] | undefined => {
    const docCache = get().documents[id];
    if (!docCache) return undefined;

    docCache.lastAccessed = Date.now();
    return docCache.bookmarks;
  },

  fetchBookmarks: async (id: string): Promise<Result<Bookmark[]>> => {
    const existing = get().documents[id]?.bookmarks;

    if (existing && existing.length > 0) {
      return { ok: true, data: existing };
    }

    const result = await fetchBookmarks(id);

    if (!result.ok) {
      return { ok: false, error: result.error };
    }

    set((state) => {
      const newDocuments = { ...state.documents };
      const docCache = getOrCreateDocCache(newDocuments, id);
      docCache.bookmarks = result.data.items;
      docCache.lastAccessed = Date.now();
      newDocuments[id] = docCache;

      return { documents: newDocuments };
    });

    return { ok: true, data: result.data.items };
  },

  getAnnotations: (id: string) => {
    const docCache = get().documents[id];
    if (!docCache) return undefined;

    docCache.lastAccessed = Date.now();
    return docCache.annotations;
  },

  fetchAnnotations: async (id: string): Promise<Result<Annotation[]>> => {
    const existing = get().documents[id]?.annotations;

    if (existing && existing.length > 0) {
      return { ok: true, data: existing };
    }

    const result = await fetchAnnotations(id);

    if (!result.ok) {
      return { ok: false, error: result.error };
    }

    set((state) => {
      const newDocuments = { ...state.documents };
      const docCache = getOrCreateDocCache(newDocuments, id);
      docCache.annotations = result.data;
      docCache.lastAccessed = Date.now();
      newDocuments[id] = docCache;

      return { documents: newDocuments };
    });

    return { ok: true, data: result.data };
  },

  setInfo: (id, info) => {
    set((state) => {
      const newDocuments = { ...state.documents };
      const docCache = getOrCreateDocCache(newDocuments, id);
      docCache.info = info;
      return { documents: newDocuments };
    });
  },

  getInfo: (id) => {
    const docCache = get().documents[id];
    if (!docCache) return undefined;

    docCache.lastAccessed = Date.now();
    return docCache.info;
  },

  fetchInfo: async (id) => {
    const { getInfo, setInfo } = get();

    if (getInfo(id)) return;

    try {
      const result = await fetchPdfInfo(id);

      if (result.ok) {
        setInfo(id, result.data);
      } else {
        console.error("Failed to fetch PDF info:", result.error);
      }
    } catch (error) {
      console.error("Error fetching PDF info:", error);
    }
  },

  purgeDocument: (id) => {
    set((state) => {
      const newDocuments = { ...state.documents };
      const docCache = newDocuments[id];

      if (docCache) {
        const totalMemoryMb = state.totalMemoryMb - docCache.memoryMb;
        delete newDocuments[id];
        return { documents: newDocuments, totalMemoryMb };
      }

      return state;
    });
  },

  clear: () => {
    set({ documents: {}, totalMemoryMb: 0 });
  },
}));
