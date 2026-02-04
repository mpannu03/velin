import { fetchBookmarks } from '@/shared/tauri';
import { Bookmarks } from '@/shared/types';
import { create } from 'zustand';

type BookmarksCacheState = {
  bookmarksCache: Record<string, Bookmarks>;
  errorCache: Record<string, string | null>;
  isLoading: Record<string, boolean>;

  fetchBookmarks: (id: string) => Promise<void>;
  getBookmarks: (id: string) => Bookmarks | undefined;
};

export const usePdfBookmarksStore = create<BookmarksCacheState>((set, get) => ({
  bookmarksCache: {},
  errorCache: {},
  isLoading: {},

  fetchBookmarks: async (id: string) => {
    if (get().bookmarksCache[id] || get().isLoading[id]) return;

    set((state) => ({
      isLoading: { ...state.isLoading, [id]: true },
      errorCache: { ...state.errorCache, [id]: null }
    }));

    const result = await fetchBookmarks(id);

    set((state) => {
      const isLoading = { ...state.isLoading };
      delete isLoading[id];

      if (result.ok) {
        return {
          isLoading,
          bookmarksCache: { ...state.bookmarksCache, [id]: result.data },
          errorCache: { ...state.errorCache }
        };
      } else {
        return {
          isLoading,
          bookmarksCache: { ...state.bookmarksCache },
          errorCache: { ...state.errorCache, [id]: result.error }
        };
      }
    });
  },

  getBookmarks: (id: string) => get().bookmarksCache[id],
}));
