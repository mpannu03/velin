import { fetchPdfInfo } from "@/shared/tauri";
import { useEffect, useState } from "react";
import { PdfInfo } from "@/shared/types";

export function usePdfInfo(
  id: string,
) {
  const [info, setInfo] = useState<PdfInfo | null>(null)

  useEffect(() => {
    let cancelled = false

    fetchPdfInfo(id)
      .then((info) => {
        if (!cancelled) {
          setInfo(info)
        }
      })
      .catch((err) => {
        if (!cancelled) {
          console.error("Failed to fetch PDF info", err)
          setInfo(null)
        }
      })

    return () => {
      cancelled = true
    }
  }, [id])

  return info
}