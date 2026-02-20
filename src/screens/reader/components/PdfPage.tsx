import { JSX, useEffect, useRef } from "react";
import { Box, Center, Loader } from "@mantine/core";
import { usePdfInfo, usePdfPage, usePdfText } from "../hooks";
import { TextLayer, SearchHighlightLayer } from "./";
import { SidebarPanel, usePdfViewerStore, useDictionaryStore } from "../stores";

type PdfPageProps = {
  id: string;
  pageIndex: number;
  width: number;
  onRendered?: () => void;
  aspectRatio: number;
  isVisible?: boolean; // Track if page is currently visible
};

export function PdfPage({ id, pageIndex, width, onRendered, aspectRatio, isVisible = true }: PdfPageProps): JSX.Element {
  const { page, error, loading } = usePdfPage(id, pageIndex, width, isVisible);
  const { text: textItems, pageWidth } = usePdfText(id, pageIndex);
  const { info } = usePdfInfo(id);

  const canvasRef = useRef<HTMLCanvasElement>(null);
  const bitmapRef = useRef<ImageBitmap | null>(null);

  const currentToolbar = usePdfViewerStore((state) => state.states[id].tool);
  const setSidebar = usePdfViewerStore((state) => state.setSidebar);
  const { setQuery, search } = useDictionaryStore();

  const onTextSelected = (selectedText: string) => {
    if (currentToolbar !== "dictionary") return;

    setQuery(id, selectedText);
    search(id, selectedText);
    setSidebar(id, SidebarPanel.Dictionary);
  };

  useEffect(() => {
    if (!page || !canvasRef.current) return;

    let cancelled = false;

    (async () => {
      const canvas = canvasRef.current!;
      
      const useOffscreen = typeof OffscreenCanvas !== 'undefined' && !isVisible;
      
      let ctx: CanvasRenderingContext2D | OffscreenCanvasRenderingContext2D | null;
      let offscreenCanvas: OffscreenCanvas | null = null;
      
      if (useOffscreen) {
        offscreenCanvas = new OffscreenCanvas(page.width, page.height);
        ctx = offscreenCanvas.getContext("2d");
      } else {
        canvas.width = page.width;
        canvas.height = page.height;
        ctx = canvas.getContext("2d");
      }
      
      if (!ctx) return;

      ctx.imageSmoothingEnabled = false;

      if (!page.pixels || page.pixels.length === 0) {
        console.warn("Received empty image data for page:", pageIndex);
        return;
      }

      const bytes =
        page.pixels instanceof Uint8Array
          ? page.pixels
          : new Uint8Array(page.pixels);

      const byteCopy = new Uint8Array(bytes);
      const blob = new Blob([byteCopy], { type: "image/webp" });

      if (bitmapRef.current) {
        bitmapRef.current.close();
        bitmapRef.current = null;
      }

      const bitmap = await createImageBitmap(blob);

      if (cancelled) {
        bitmap.close();
        return;
      }

      bitmapRef.current = bitmap;

      ctx.clearRect(0, 0, page.width, page.height);
      ctx.drawImage(bitmap, 0, 0);

      if (useOffscreen && offscreenCanvas) {
        const mainCtx = canvas.getContext("2d");
        if (mainCtx) {
          canvas.width = page.width;
          canvas.height = page.height;
          const transferBitmap = await createImageBitmap(offscreenCanvas as any);
          mainCtx.drawImage(transferBitmap, 0, 0);
          transferBitmap.close();
        }
      }

      onRendered?.();
    })();

    return () => {
      cancelled = true;
      if (bitmapRef.current) {
        bitmapRef.current.close();
        bitmapRef.current = null;
      }
    };
  }, [page, pageIndex, onRendered, isVisible]);

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

  const displayWidth = width / 2;
  const displayHeight = page ? (width * (page.height / page.width)) / 2 : (width * aspectRatio) / 2;
  const scale = pageWidth 
    ? displayWidth / pageWidth 
    : (info 
      ? displayWidth / info.width 
      : (page 
        ? displayWidth / page.width 
        : 1));

  return (
    <Box
      style={{
        display: "flex",
        justifyContent: "center",
        marginBottom: 16
      }}
    >
      <Box
        style={{
          position: "relative",
          width: `${displayWidth}px`,
          height: `${displayHeight}px`,
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
          backgroundColor: 'white',
        }}
      >
        <canvas
          ref={canvasRef}
          style={{
            width: `100%`,
            height: `100%`,
            display: page ? 'block' : 'none',
            opacity: loading && page ? 0.95 : 1,
            transition: 'opacity 0.2s ease-in-out',
          }}
        />
        {textItems && info && (
          <TextLayer
            textItems={textItems}
            scale={scale}
            width={displayWidth}
            height={displayHeight}
            onTextSelected={onTextSelected}
          />
        )}
        {info && (
          <SearchHighlightLayer
            id={id}
            pageIndex={pageIndex}
            scale={scale}
          />
        )}
      </Box>
    </Box>
  );
}
