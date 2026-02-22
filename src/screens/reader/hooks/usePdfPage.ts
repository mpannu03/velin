import { useEffect, useState } from "react";
import { renderPage } from "@/services/tauri";
import { pdfRenderQueue } from "../renderer";
import { useDocumentCacheStore } from "../stores";
import { RenderedPage } from "../types"

type PdfPageState = {
  page: RenderedPage | null;
  error: string | null;
  loading: boolean;
}

export function usePdfPage(
  id: string,
  pageIndex: number,
  targetWidth: number,
  isVisible: boolean = true
) {
  const { addPage, getPage, getAnyPage } = useDocumentCacheStore();

  const [state, setState] = useState<PdfPageState>(() => {
    const cached = getPage(id, pageIndex, targetWidth);
    if (cached) return { page: cached, error: null, loading: false };
    
    const fallback = getAnyPage(id, pageIndex);
    return { page: fallback || null, error: null, loading: true };
  });

  useEffect(() => {
    let cancelled = false;

    const cached = getPage(id, pageIndex, targetWidth);
    const fallback = getAnyPage(id, pageIndex);

    if (cached) {
      setState({
        page: cached,
        error: null,
        loading: false,
      });
      return;
    }

    // Update state to loading, but keep fallback page if available
    setState({
      page: fallback || null,
      error: null,
      loading: true,
    });

    const abortController = new AbortController();
    
    // Visible pages get higher priority (100), offscreen pages get lower (0)
    const priority = isVisible ? 100 : 0;

    pdfRenderQueue.enqueue(
      () => renderPage(id, pageIndex, targetWidth),
      abortController.signal,
      priority
    ).then((result) => {
      if (cancelled || abortController.signal.aborted) return;

      if (result.ok) {
        addPage(id, pageIndex, result.data);
        setState({
          page: result.data,
          error: null,
          loading: false,
        });
      } else {
        setState(s => ({
          ...s,
          error: result.error,
          loading: false,
        }));
      }
    }).catch((err) => {
      // Ignore abort errors
      if (err.message !== "Aborted" && !cancelled) {
        console.error(err);
      }
    });

    return () => {
      cancelled = true;
      abortController.abort();
    }
  }, [id, pageIndex, targetWidth, isVisible, getPage, addPage, getAnyPage])

  return state;
}
