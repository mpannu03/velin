import { fetchTextByPage } from "@/shared/tauri";
import { PageText } from "@/shared/types";
import { create } from "zustand";

type TextCacheState = {
  textCache: Map<string, PageText>;
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
        textCache.set(key, result.data);
      } else {
        errorCache.set(key, result.error);
      }

      return { isLoading, textCache, errorCache };
    });
  },

  getText: (id: string, page: number) => get().textCache.get(`${id}:${page}`),

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
