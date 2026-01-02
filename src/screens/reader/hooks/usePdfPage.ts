import { renderPage } from "@/shared/tauri";
import { RenderedPage } from "../types"
import { useEffect, useState } from "react";

type PdfPageState = {
  page: RenderedPage | null;
  error: string | null;
  loading: boolean;
}

export function usePdfPage(
  id: string,
  pageIndex: number,
  targetWidth: number
) {
  const [state, setState] = useState<PdfPageState>({
    page: null,
    error: null,
    loading: true,
  });

  useEffect(() => {
    let cancelled = false

    setState({ page: null, error: null, loading: true});

    renderPage(id, pageIndex, targetWidth).then((result) => {
      if (cancelled) return;

      if (result.ok) {
        setState({
          page: result.data,
          error: null,
          loading: false,
        });
      } else {
        setState({
          page: null,
          error: result.error,
          loading: false,
        });
      }
    });

    return () => {
      cancelled = true
    }
  }, [id, pageIndex, targetWidth])

  return state;
}
