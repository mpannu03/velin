import { JSX, useEffect, useRef } from "react";
import { usePdfPage } from "../hooks";
import { Box, Center, Loader } from "@mantine/core";

type PdfPageProps = {
  id: string;
  pageIndex: number;
  onRendered?: () => void;
};

export function PdfPage({ id, pageIndex, onRendered }: PdfPageProps): JSX.Element {
  const { page, error, loading} = usePdfPage(id, pageIndex, 500);

  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    if (!page || !canvasRef.current) return;

    const canvas = canvasRef.current;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    canvas.width = page.width;
    canvas.height = page.height;

    canvas.style.width = `${page.width / 2}px`;
    canvas.style.height = `${page.height / 2}px`;

    ctx.imageSmoothingEnabled = false;

    const imageData = new ImageData(
      new Uint8ClampedArray(page.pixels),
      page.width,
      page.height
    );

    ctx.putImageData(imageData, 0, 0);

    onRendered?.();
  }, [page]);

  if (loading) {
    return <Center mb={16}>
      <Center w="250px" h="445px" bg="white"><Loader /></Center>
    </Center>
  }

  if (error) {
    return <Center>Loading Error: {error}</Center>
  }

  if (!page) {
    return <div style={{
        display: "flex",
        justifyContent: "center",
        margin: 16
      }}>Loading page…</div>
  }

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
  );
}