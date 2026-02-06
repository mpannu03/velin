import { JSX, useEffect, useRef } from "react";
import { usePdfPage } from "../hooks";
import { Box, Center, Loader } from "@mantine/core";

type PdfPageProps = {
  id: string;
  pageIndex: number;
  width: number;
  onRendered?: () => void;
  aspectRatio: number;
};

export function PdfPage({ id, pageIndex, width, onRendered, aspectRatio }: PdfPageProps): JSX.Element {
  const { page, error, loading } = usePdfPage(id, pageIndex, width);

  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    if (!page || !canvasRef.current) return;

    let cancelled = false;

    (async () => {
      const canvas = canvasRef.current!;
      const ctx = canvas.getContext("2d", { willReadFrequently: false });
      if (!ctx) return;

      canvas.width = page.width;
      canvas.height = page.height;

      ctx.imageSmoothingEnabled = false;  

      const imageData = new ImageData(
        page.pixels instanceof Uint8ClampedArray
          ? (page.pixels as unknown as Uint8ClampedArray<ArrayBuffer>)
          : new Uint8ClampedArray(page.pixels),
        page.width,
        page.height
      );

      const bitmap = await createImageBitmap(imageData);
      if (cancelled) {
        bitmap.close();
        return;
      }

      ctx.drawImage(bitmap, 0, 0);
      bitmap.close();

      onRendered?.();
    })();

    return () => {
      cancelled = true;
    };
  }, [page]);

  if (loading && !page) {
    return (
      <Center mb={16}>
        <Center w={`${width / 2}px`} h={`${(width * aspectRatio) / 2}px`} bg="white">
          <Loader />
        </Center>
      </Center>
    );
  }

  if (error && !page) {
    return <Center mb={16}>Loading Error: {error}</Center>;
  }

  return (
    <Box
      style={{
        display: "flex",
        justifyContent: "center",
        marginBottom: 16
      }}
    >
      <canvas
        ref={canvasRef}
        style={{
          width: `${width / 2}px`,
          height: page ? `${(width * (page.height / page.width)) / 2}px` : `${(width * aspectRatio) / 2}px`,
          display: page ? 'block' : 'none',
          backgroundColor: 'white',
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
        }}
      />
    </Box>
  );
}