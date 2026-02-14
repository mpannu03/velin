import { create } from 'zustand';
import { invoke } from '@tauri-apps/api/core';
import { SearchHit } from '@/shared/types';

interface SearchState {
  query: string;
  results: Record<string, SearchHit[]>;
  currentIndex: number;
  isSearching: boolean;
  error: string | null;

  setQuery: (query: string) => void;
  search: (id: string, query: string) => Promise<void>;
  nextResult: (id: string) => void;
  prevResult: (id: string) => void;
  clearResult: (id: string) => void;
  clearResults: () => void;
}

export const useSearchStore = create<SearchState>((set, get) => ({
  query: '',
  results: {},
  currentIndex: -1,
  isSearching: false,
  error: null,

  setQuery: (query) => set({ query }),

  search: async (id, query) => {
    if (!query.trim()) {
      set({ results: {}, currentIndex: -1, isSearching: false });
      return;
    }

    set({ isSearching: true, error: null });
    try {
      const results = await invoke<SearchHit[]>('search_document', { id, query });
      set({ results: { ...get().results, [id]: results }, currentIndex: results.length > 0 ? 0 : -1, isSearching: false });
    } catch (err) {
      set({ error: err as string, isSearching: false });
    }
  },

  nextResult: (id: string) => {
    const { results, currentIndex } = get();
    if (results[id].length === 0) return;
    set({ currentIndex: (currentIndex + 1) % results[id].length });
  },

  prevResult: (id: string) => {
    const { results, currentIndex } = get();
    if (results[id].length === 0) return;
    set({ currentIndex: (currentIndex - 1 + results[id].length) % results[id].length });
  },

  clearResult: (id: string) => set({ results: { ...get().results, [id]: [] }, currentIndex: -1 }),

  clearResults: () => set({ query: '', results: {}, currentIndex: -1, error: null }),
}));
