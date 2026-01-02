import { fetchPdfInfo } from "@/shared/tauri";
import { useEffect, useState } from "react";
import { PdfInfo } from "@/shared/types";

type PdfInfoState = {
  info: PdfInfo | null;
  error: string | null;
  loading: boolean;
}

export function usePdfInfo(
  id: string,
) {
  const [state, setState] = useState<PdfInfoState>({
    info: null,
    error: null,
    loading: true,
  });

  useEffect(() => {
    let cancelled = false

    setState({ info: null, error: null, loading: true });

    fetchPdfInfo(id).then((result) => {
      if (cancelled) return;

      if (result.ok) {
        setState({
          info: result.data,
          error: null,
          loading: false,
        });
      } else {
        setState({
          info: null,
          error: result.error,
          loading: false,
        });
      }
    });

    return () => {
      cancelled = true
    }
  }, [id]);

  return state
}