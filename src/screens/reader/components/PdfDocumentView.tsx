import { useEffect, useState } from "react"
import { Stack } from "@mantine/core"
import { PdfPageCanvas } from "./PdfPageCanvas"
import { usePdfPage } from "../hooks/usePdfPage"
import { RenderedPage } from "../types"

type Props = {
  docId: string
  pageCount: number
}

export function PdfDocumentView({ docId, pageCount }: Props) {
  const [pages, setPages] = useState<(RenderedPage | null)[]>(
    Array(pageCount).fill(null)
  )

  useEffect(() => {
    let cancelled = false

    const loadFirstPages = async () => {
      for (let i = 0; i < Math.min(3, pageCount); i++) {
        const { load } = usePdfPage(docId, i, 1.0)
        const page = await load()
        if (cancelled) return

        setPages(prev => {
          const next = [...prev]
          next[i] = page
          return next
        })
      }
    }

    loadFirstPages()
    return () => {
      cancelled = true
    }
  }, [docId, pageCount])

  return (
    <Stack gap="md">
      {pages.map((page, index) => (
        <PdfPageCanvas
          key={index}
          page={page}
          scale={1.0}
        />
      ))}
    </Stack>
  )
}
