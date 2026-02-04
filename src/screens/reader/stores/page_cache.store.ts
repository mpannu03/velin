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

      if (newPages.has(key)) {
        newPages.delete(key);
      } else {
        memoryMb += pageMb;
      }

      newPages.set(key, page);

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

      return { pages: newPages };
    });
  },

  getPage: (id, pageIndex, width) => {
    const keyPrefix = `${id}:${pageIndex}:${width}x`;
    return [...get().pages.entries()].find(([k]) => k.startsWith(keyPrefix))?.[1];
  },

  getAnyPage: (id, pageIndex) => {
    const keyPrefix = `${id}:${pageIndex}:`;
    const matches = [...get().pages.entries()]
      .filter(([k]) => k.startsWith(keyPrefix))
      .map(([_, v]) => v);
        
    if (matches.length === 0) return undefined;
    return matches.sort((a, b) => b.width - a.width)[0];
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
  return (page.width * page.height * BYTES_PER_PIXEL) / (1024 * 1024);
}
