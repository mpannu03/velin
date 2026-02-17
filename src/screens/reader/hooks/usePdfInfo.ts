import { useEffect } from "react";
import { useDocumentCacheStore } from "../stores";

export function usePdfInfo(id: string) {
  const getInfo = useDocumentCacheStore(s => s.getInfo);
  const fetchInfo = useDocumentCacheStore(s => s.fetchInfo);
  const info = getInfo(id);

  useEffect(() => {
    fetchInfo(id);
  }, [id, fetchInfo]);

  const isLoading = !info;

  return {
    info: info || null,
    error: null,
    loading: isLoading,
  };
}