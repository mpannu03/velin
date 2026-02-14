import { create } from "zustand";
import { SearchResult, createDictionaryEngine } from "@/services/dictionary";

interface DictionaryState {
    query: string;
    results: Record<string, SearchResult>;
    isSearching: boolean;
    error: string | null;

    setQuery: (query: string) => void;
    search: (id: string, query: string) => Promise<void>;
    clearResults: () => void;
}

export const useDictionaryStore = create<DictionaryState>((set, get) => {
    return {
        query: "",
        results: {},
        isSearching: false,
        error: null,

        setQuery: (query: string) => set({ query }),

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

        clearResults: () => set({ query: "", results: {}, isSearching: false, error: null }),
    };
})