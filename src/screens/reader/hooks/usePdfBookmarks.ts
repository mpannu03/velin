import { useEffect } from "react";
import { usePdfBookmarksStore } from "../stores";

export function usePdfBookmarks(id: string) {
  const bookmarks = usePdfBookmarksStore(s => s.bookmarksCache[id]);
  const error = usePdfBookmarksStore(s => s.errorCache[id]);
  const loading = usePdfBookmarksStore(s => s.isLoading[id]);
  const fetchBookmarks = usePdfBookmarksStore(s => s.fetchBookmarks);

  useEffect(() => {
    fetchBookmarks(id);
  }, [id, fetchBookmarks]);

  const isLoading = loading || (!bookmarks && !error);

  return {
    bookmarks: bookmarks || null,
    error: error || null,
    loading: isLoading,
  };
}