import { useEffect, useState } from "react";
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

  useEffect(() => {
    if (cachedTile) {
      if (state.loading || state.tile !== cachedTile) {
        setState({ tile: cachedTile, error: null, loading: false });
      }
      return;
    }

    let cancelled = false;
    setState({ tile: null, error: null, loading: true });

    const abortController = new AbortController();
    const taskKey = `${id}:${pageIndex}:${targetWidth}:${x}_${y}_${width}x${height}`;

    pdfRenderQueue
      .enqueue(
        () => renderTile(id, pageIndex, targetWidth, x, y, width, height),
        abortController.signal,
        priority,
        taskKey,
      )
      .then((result) => {
        if (cancelled) return;

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
        if (err.message !== "Aborted" && !cancelled) {
          console.error(err);
        }
      });

    return () => {
      cancelled = true;
      abortController.abort();
    };
  }, [
    id,
    pageIndex,
    targetWidth,
    x,
    y,
    width,
    height,
    priority,
    addTile,
    cachedTile,
  ]);

  return state;
}
