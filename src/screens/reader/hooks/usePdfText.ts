import { useEffect } from "react";
import { useTextCacheStore } from "../stores/textCache.store";

export function usePdfText(id: string, page: number) {
  const key = `${id}:${page}`;
  const text = useTextCacheStore(s => s.textCache.get(key));
  const error = useTextCacheStore(s => s.errorCache.get(key));
  const loading = useTextCacheStore(s => s.isLoading.get(key));
  const fetchText = useTextCacheStore(s => s.fetchText);

  useEffect(() => {
    fetchText(id, page);
  }, [id, fetchText, page]);

  const isLoading = loading || (!text && !error && loading !== false);

  return {
    text: text || null,
    error: error || null,
    loading: isLoading,
  };
}