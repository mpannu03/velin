import { useEffect } from "react";
import { usePdfInfoStore } from "../stores/pdf_info.store";

export function usePdfInfo(id: string) {
  const info = usePdfInfoStore(s => s.infoCache[id]);
  const error = usePdfInfoStore(s => s.errorCache[id]);
  const loading = usePdfInfoStore(s => s.isLoading[id]);
  const fetchInfo = usePdfInfoStore(s => s.fetchInfo);

  useEffect(() => {
    fetchInfo(id);
  }, [id, fetchInfo]);

  const isLoading = loading || (!info && !error);

  return {
    info: info || null,
    error: error || null,
    loading: isLoading,
  };
}