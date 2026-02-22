import { useEffect, useState } from "react";
import { useDocumentCacheStore } from "../stores";

export function usePdfBookmarks(id: string) {
  const bookmarks = useDocumentCacheStore(s => s.documents[id]?.bookmarks);
  const fetchBookmarks = useDocumentCacheStore(s => s.fetchBookmarks);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      const result = await fetchBookmarks(id);
      if (!result.ok) {
        setError(result.error);
      }
    })();
  }, [id, fetchBookmarks]);

  return {
    bookmarks: bookmarks ?? null,
    error: error,
    loading: !bookmarks,
  };
}