import { useEffect } from "react";
import { useDocumentCacheStore } from "../stores";
import { TextItem } from "@/shared/types";

type PdfTextState = {
  text: TextItem[] | null;
  pageWidth: number;
  pageHeight: number;
  error: string | null;
  loading: boolean;
};

export function usePdfText(id: string, page: number): PdfTextState {
  const fetchText = useDocumentCacheStore((s) => s.fetchText);

  // Reactively subscribe to the specific text cache entry.
  // When fetchText populates the cache, this selector re-evaluates and triggers re-render.
  const data = useDocumentCacheStore((s) => s.documents[id]?.text[page]);

  // Initial fetch
  useEffect(() => {
    fetchText(id, page);
  }, [id, fetchText, page]);

  return {
    text: data?.items || null,
    pageWidth: data?.width || 0,
    pageHeight: data?.height || 0,
    error: null,
    loading: !data,
  };
}
