import { useEffect, useRef } from "react"
import { Box } from "@mantine/core"
import { RenderedPage } from "../types"

type Props = {
  page: RenderedPage | null
  scale: number
}

export function PdfPageCanvas({ page, scale }: Props) {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    if (!page || !canvasRef.current) return

    const canvas = canvasRef.current
    const ctx = canvas.getContext("2d")
    if (!ctx) return

    canvas.width = page.width * scale
    canvas.height = page.height * scale

    const imageData = new ImageData(
      new Uint8ClampedArray(page.pixels),
      page.width,
      page.height
    )

    ctx.save()
    ctx.scale(scale, scale)
    ctx.putImageData(imageData, 0, 0)
    ctx.restore()
  }, [page, scale])

  return (
    <Box
      style={{
        display: "flex",
        justifyContent: "center",
        marginBottom: 16
      }}
    >
      <canvas ref={canvasRef} />
    </Box>
  )
}
