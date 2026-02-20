import { useEffect } from "react";
import { useDocumentCacheStore } from "../stores";

export function usePdfInfo(id: string) {
  const info = useDocumentCacheStore(s => s.documents.get(id)?.info);
  const fetchInfo = useDocumentCacheStore(s => s.fetchInfo);

  useEffect(() => {
    fetchInfo(id);
  }, [id, fetchInfo]);

  return {
    info: info ?? null,
    error: null,
    loading: !info,
  };
}