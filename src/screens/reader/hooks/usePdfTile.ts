import { useEffect, useRef, useState } from "react";
import { renderTile } from "@/services/tauri";
import { pdfRenderQueue } from "../renderer";
import { useDocumentCacheStore } from "../stores";
import { RenderedTile } from "../types";

type PdfTileState = {
  tile: RenderedTile | null;
  error: string | null;
  loading: boolean;
};

export function usePdfTile(
  id: string,
  pageIndex: number,
  targetWidth: number,
  x: number,
  y: number,
  width: number,
  height: number,
  priority: number = 100,
) {
  const addTile = useDocumentCacheStore((s) => s.addTile);
  const abortControllerRef = useRef<AbortController | null>(null);

  // 👇 Optimized: Extract ONLY the specific tile needed
  const cachedTile = useDocumentCacheStore((s) => {
    const doc = s.documents[id];
    if (!doc) return undefined;
    const key = `${pageIndex}:${targetWidth}:${x}_${y}_${width}x${height}`;
    return doc.tiles[key];
  });

  const [state, setState] = useState<PdfTileState>(() => ({
    tile: cachedTile || null,
    error: null,
    loading: !cachedTile,
  }));

  // Update state if cache changes (Zustand side)
  useEffect(() => {
    if (cachedTile && (state.loading || state.tile !== cachedTile)) {
      setState({ tile: cachedTile, error: null, loading: false });
    }
  }, [cachedTile, state.loading, state.tile]);

  useEffect(() => {
    if (cachedTile) return;

    const taskKey = `${id}:${pageIndex}:${targetWidth}:${x}_${y}_${width}x${height}`;

    // 🚀 PERSISTENCE FIX: If we have an active controller, don't abort it
    // just because priority changed. Only abort if component unmounts
    // or if the identity of the tile changes (handled by deps).
    if (!abortControllerRef.current) {
      abortControllerRef.current = new AbortController();
    }

    setState((s) => (s.loading ? s : { ...s, loading: true }));

    pdfRenderQueue
      .enqueue(
        () => renderTile(id, pageIndex, targetWidth, x, y, width, height),
        abortControllerRef.current.signal,
        priority,
        taskKey,
      )
      .then((result) => {
        if (result.ok) {
          addTile(id, pageIndex, targetWidth, result.data);
          setState({
            tile: result.data,
            error: null,
            loading: false,
          });
        } else {
          setState({
            tile: null,
            error: result.error,
            loading: false,
          });
        }
      })
      .catch((err) => {
        if (err.message !== "Aborted") {
          console.error(err);
        }
      });

    // We only clean up on UNMOUNT or IDENTITY CHANGE.
    // We do NOT abort on priority change anymore.
  }, [id, pageIndex, targetWidth, x, y, width, height, addTile, cachedTile]);

  // Handle Abort on IDENTITY CHANGE or UNMOUNT
  useEffect(() => {
    return () => {
      abortControllerRef.current?.abort();
      abortControllerRef.current = null;
    };
  }, [id, pageIndex, targetWidth, x, y, width, height]);

  // 🚀 SEPARATE: When priority changes, we simply re-enqueue.
  // pdfRendererQueue already handles escalation if taskKey is the same.
  useEffect(() => {
    if (cachedTile || !abortControllerRef.current) return;

    const taskKey = `${id}:${pageIndex}:${targetWidth}:${x}_${y}_${width}x${height}`;
    pdfRenderQueue.enqueue(
      () => renderTile(id, pageIndex, targetWidth, x, y, width, height),
      abortControllerRef.current.signal,
      priority,
      taskKey,
    );
  }, [priority]);

  return state;
}
