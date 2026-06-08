import { useEffect } from "react";
import { useDocumentCacheStore } from "../stores";

export function usePdfText(id: string, page: number) {
  const getText = useDocumentCacheStore(s => s.getText);
  const fetchText = useDocumentCacheStore(s => s.fetchText);
  const data = getText(id, page);

  useEffect(() => {
    fetchText(id, page);
  }, [id, fetchText, page]);

  const isLoading = !data;

  return {
    text: data?.items || null,
    pageWidth: data?.width || 0,
    pageHeight: data?.height || 0,
    error: null,
    loading: isLoading,
  };
}