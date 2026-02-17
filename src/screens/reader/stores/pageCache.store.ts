import { create } from 'zustand';
import { RenderedPage } from '../types';

type PageCacheState = {
  pages: Map<string, RenderedPage>;
  memoryMb: number;
  addPage: (id: string, pageIndex: number, page: RenderedPage) => void;
  getPage: (id: string, pageIndex: number, width: number) => RenderedPage | undefined;
  getAnyPage: (id: string, pageIndex: number) => RenderedPage | undefined;
  purgeDocument: (id: string) => void;
  clear: () => void;
};

const MAX_CACHE_MB = 256;
const BYTES_PER_PIXEL = 4;

export const usePageCacheStore = create<PageCacheState>((set, get) => ({
  pages: new Map(),
  memoryMb: 0,

  addPage: (id, pageIndex, page) => {
    const key = `${id}:${pageIndex}:${page.width}x${page.height}`;
    const pageMb = estimatePageMB(page);
    set((state) => {
      const newPages = new Map(state.pages);
      let memoryMb = state.memoryMb;

      // If page already exists, subtract its old size first
      if (newPages.has(key)) {
        const oldPage = newPages.get(key);
        if (oldPage) {
          memoryMb -= estimatePageMB(oldPage);
        }
      }

      // Add new page and its size
      newPages.set(key, page);
      memoryMb += pageMb;

      while (memoryMb > MAX_CACHE_MB && newPages.size > 0) {
        let keyToEvict: string | undefined;

        // Prefer evicting pages from background documents
        for (const k of newPages.keys()) {
          if (!k.startsWith(`${id}:`)) {
            keyToEvict = k;
            break;
          }
        }

        // Fallback to pure LRU
        if (!keyToEvict) {
          keyToEvict = newPages.keys().next().value;
        }

        if (!keyToEvict) break;

        const evicted = newPages.get(keyToEvict);
        if (evicted) {
          memoryMb -= estimatePageMB(evicted);
        }

        newPages.delete(keyToEvict);
      }

      return { pages: newPages, memoryMb };
    });
  },

  getPage: (id, pageIndex, width) => {
    const keyPrefix = `${id}:${pageIndex}:${width}x`;
    const pages = get().pages;
    
    // Use direct iteration instead of spreading into array
    for (const [key, value] of pages.entries()) {
      if (key.startsWith(keyPrefix)) {
        return value;
      }
    }
    
    return undefined;
  },

  getAnyPage: (id, pageIndex) => {
    const keyPrefix = `${id}:${pageIndex}:`;
    const pages = get().pages;
    let bestMatch: RenderedPage | undefined;
    let maxWidth = 0;
    
    // Find the page with the highest width using direct iteration
    for (const [key, value] of pages.entries()) {
      if (key.startsWith(keyPrefix) && value.width > maxWidth) {
        maxWidth = value.width;
        bestMatch = value;
      }
    }
    
    return bestMatch;
  },

  purgeDocument: (id) => set((state) => {
    const newPages = new Map(state.pages);
    const prefix = `${id}:`;
    for (const key of newPages.keys()) {
      if (key.startsWith(prefix)) {
        newPages.delete(key);
      }
    }
    return { pages: newPages };
  }),

  clear: () => set({ pages: new Map() }),
}));

function estimatePageMB(page: RenderedPage): number {
  // Since we're using WebP compression, use actual byte size
  // WebP is typically 5-10% of raw pixel size
  if (page.pixels) {
    return page.pixels.length / (1024 * 1024);
  }
  
  // Fallback to conservative estimate if pixels not available
  return (page.width * page.height * BYTES_PER_PIXEL * 0.08) / (1024 * 1024);
}
