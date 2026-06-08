import { create } from "zustand";
import { SearchResult, createDictionaryEngine } from "@/services/dictionary";

interface DictionaryState {
    queries: Record<string, string>;
    results: Record<string, SearchResult>;
    isSearching: boolean;
    error: string | null;

    setQuery: (id: string, query: string) => void;
    search: (id: string, query: string) => Promise<void>;
    clearResult: (id: string) => void;
    clearResults: () => void;
}

export const useDictionaryStore = create<DictionaryState>((set, get) => {
    return {
        queries: {},
        results: {},
        isSearching: false,
        error: null,

        setQuery: (id: string, query: string) => set({ queries: { ...get().queries, [id]: query } }),

        search: async (id: string, query: string) => {
          const engine = await createDictionaryEngine();

          set({ isSearching: true });
          try {
              const result = await engine.search(query);
              set({ results: { ...get().results, [id]: result }, isSearching: false });
          } catch (error) {
              set({ error: "Failed to fetch dictionary results", isSearching: false });
          }
        },

        clearResult: (id: string) => set({ 
            results: { ...get().results, [id]: { noun: [], verb: [], adj: [], adv: [] } },
            queries: { ...get().queries, [id]: "" } 
        }),

        clearResults: () => set({ queries: {}, results: {}, isSearching: false, error: null }),
    };
})