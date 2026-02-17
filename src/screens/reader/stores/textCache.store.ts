import { create } from "zustand";
import { fetchTextByPage } from "@/services/tauri";
import { PageText } from "@/shared/types";

// Maximum number of pages to cache (prevents unbounded growth)
const MAX_TEXT_CACHE_PAGES = 100;

type TextCacheEntry = {
  data: PageText;
  lastAccessed: number;
};

type TextCacheState = {
  textCache: Map<string, TextCacheEntry>;
  errorCache: Map<string, string | null>;
  isLoading: Map<string, boolean>;

  fetchText: (id: string, page: number) => Promise<void>;
  getText: (id: string, page: number) => PageText | undefined;
  removeText: (id: string) => void;
};

export const useTextCacheStore = create<TextCacheState>((set, get) => ({
  textCache: new Map(),
  errorCache: new Map(),
  isLoading: new Map(),

  fetchText: async (id: string, page: number) => {
    const key = `${id}:${page}`;
    if (get().textCache.has(key) || get().isLoading.get(key)) return;

    set((state) => {
      const isLoading = new Map(state.isLoading);
      const errorCache = new Map(state.errorCache);
      isLoading.set(key, true);
      errorCache.set(key, null);
      return { isLoading, errorCache };
    });

    const result = await fetchTextByPage(id, page);

    set((state) => {
      const isLoading = new Map(state.isLoading);
      const textCache = new Map(state.textCache);
      const errorCache = new Map(state.errorCache);

      isLoading.delete(key);

      if (result.ok) {
        // Add new entry with timestamp
        const entry: TextCacheEntry = {
          data: result.data,
          lastAccessed: Date.now(),
        };
        textCache.set(key, entry);

        // Evict LRU entries if cache is too large
        while (textCache.size > MAX_TEXT_CACHE_PAGES) {
          let oldestKey: string | undefined;
          let oldestTime = Infinity;

          // Find least recently used entry
          for (const [k, v] of textCache.entries()) {
            if (v.lastAccessed < oldestTime) {
              oldestTime = v.lastAccessed;
              oldestKey = k;
            }
          }

          if (oldestKey) {
            textCache.delete(oldestKey);
          } else {
            break;
          }
        }
      } else {
        errorCache.set(key, result.error);
      }

      return { isLoading, textCache, errorCache };
    });
  },

  getText: (id: string, page: number) => {
    const key = `${id}:${page}`;
    const entry = get().textCache.get(key);
    
    if (entry) {
      // Update last accessed time for LRU tracking
      entry.lastAccessed = Date.now();
      return entry.data;
    }
    
    return undefined;
  },

  removeText: (id: string) =>
    set((state) => {
      const textCache = new Map(state.textCache);
      const errorCache = new Map(state.errorCache);
      const isLoading = new Map(state.isLoading);

      const prefix = `${id}:`;

      [textCache, errorCache, isLoading].forEach((map) => {
        for (const key of map.keys()) {
          if (key.startsWith(prefix)) {
            map.delete(key);
          }
        }
      });

      return { textCache, errorCache, isLoading };
    }),
}));
