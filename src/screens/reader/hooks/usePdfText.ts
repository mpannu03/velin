import { useEffect } from "react";
import { useTextCacheStore } from "../stores";

export function usePdfText(id: string, page: number) {
  const key = `${id}:${page}`;
  const getText = useTextCacheStore(s => s.getText);
  const data = getText(id, page); // Use getText() method instead of direct cache access
  const error = useTextCacheStore(s => s.errorCache.get(key));
  const loading = useTextCacheStore(s => s.isLoading.get(key));
  const fetchText = useTextCacheStore(s => s.fetchText);

  useEffect(() => {
    fetchText(id, page);
  }, [id, fetchText, page]);

  const isLoading = loading || (!data && !error && loading !== false);

  return {
    text: data?.items || null,
    pageWidth: data?.width || 0,
    pageHeight: data?.height || 0,
    error: error || null,
    loading: isLoading,
  };
}