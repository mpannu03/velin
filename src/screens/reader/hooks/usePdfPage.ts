import { renderPage } from "@/shared/tauri";
import { RenderedPage } from "../types"
import { useEffect, useState } from "react";

export function usePdfPage(
  id: string,
  pageIndex: number,
  targetWidth: number
) {
  const [page, setPage] = useState<RenderedPage | null>(null)

  useEffect(() => {
    let cancelled = false

    renderPage(id, pageIndex, targetWidth)
      .then((page) => {
        if (!cancelled) {
          setPage(page)
        }
      })
      .catch((err) => {
        if (!cancelled) {
          console.error("Failed to render page", err)
          setPage(null)
        }
      })

    return () => {
      cancelled = true
    }
  }, [id, pageIndex, targetWidth])

  return page
}
