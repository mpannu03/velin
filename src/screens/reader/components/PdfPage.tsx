import { JSX, useEffect, useRef } from "react";
import { Box, Center, Loader } from "@mantine/core";
import {
  usePdfAnnotations,
  usePdfInfo,
  usePdfPage,
  usePdfText,
} from "../hooks";
import { TextLayer, SearchHighlightLayer, AnnotationLayer } from "./";
import { SidebarPanel, usePdfViewerStore, useDictionaryStore } from "../stores";

type PdfPageProps = {
  id: string;
  pageIndex: number;
  width: number;
  onRendered?: () => void;
  aspectRatio: number;
  isVisible?: boolean;
};

export function PdfPage({
  id,
  pageIndex,
  width,
  onRendered,
  aspectRatio,
}: PdfPageProps): JSX.Element {
  const { page, error, loading } = usePdfPage(id, pageIndex, width);
  const { text: textItems, pageWidth } = usePdfText(id, pageIndex);
  const { info } = usePdfInfo(id);
  const annotations =
    usePdfAnnotations(id).annotations?.filter(
      (a) => a.page_index === pageIndex,
    ) || [];

  const canvasRef = useRef<HTMLCanvasElement>(null);

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
      const ctx = canvas.getContext("2d", { willReadFrequently: false });
      if (!ctx) return;

      canvas.width = page.width;
      canvas.height = page.height;

      ctx.imageSmoothingEnabled = false;

      if (page.pixels.length === 0) {
        console.warn("Received empty pixel data for page:", pageIndex);
        return;
      }

      const imageData = new ImageData(
        page.pixels instanceof Uint8ClampedArray
          ? (page.pixels as unknown as Uint8ClampedArray<ArrayBuffer>)
          : new Uint8ClampedArray(page.pixels),
        page.width,
        page.height,
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
        <Center
          w={`${width / 2}px`}
          h={`${(width * aspectRatio) / 2}px`}
          bg="white"
        >
          <Loader />
        </Center>
      </Center>
    );
  }

  if (error && !page) {
    return <Center mb={16}>Loading Error: {error}</Center>;
  }

  const displayWidth = width / 2;
  const displayHeight = page
    ? (width * (page.height / page.width)) / 2
    : (width * aspectRatio) / 2;
  const scale = pageWidth
    ? displayWidth / pageWidth
    : info
      ? displayWidth / info.width
      : page
        ? displayWidth / page.width
        : 1;

  return (
    <Box
      style={{
        display: "flex",
        justifyContent: "center",
        marginBottom: 16,
      }}
    >
      <Box
        style={{
          position: "relative",
          width: `${displayWidth}px`,
          height: `${displayHeight}px`,
          boxShadow: "0 1px 3px rgba(0,0,0,0.1)",
          backgroundColor: "white",
        }}
      >
        <canvas
          ref={canvasRef}
          style={{
            width: `100%`,
            height: `100%`,
            display: page ? "block" : "none",
            opacity: loading && page ? 0.95 : 1,
            transition: "opacity 0.2s ease-in-out",
          }}
        />
        {annotations && (
          <AnnotationLayer
            annotations={annotations}
            scale={scale}
            width={displayWidth}
            height={displayHeight}
          />
        )}
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
          <SearchHighlightLayer id={id} pageIndex={pageIndex} scale={scale} />
        )}
      </Box>
    </Box>
  );
}
