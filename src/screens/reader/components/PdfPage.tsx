import { JSX } from "react";
import { Box, Center, Loader } from "@mantine/core";
import { usePdfAnnotations, usePdfInfo, usePdfText } from "../hooks";
import { TextLayer, SearchHighlightLayer, AnnotationLayer } from "./";
import { SidebarPanel, usePdfViewerStore, useDictionaryStore } from "../stores";
import { TileLayer } from "./TileLayer";

type PdfPageProps = {
  id: string;
  pageIndex: number;
  width: number; // this is your renderWidth from parent
  aspectRatio: number;
  isVisible?: boolean;
};

export function PdfPage({ id, pageIndex, width }: PdfPageProps): JSX.Element {
  const { text: textItems, pageWidth } = usePdfText(id, pageIndex);
  const { info } = usePdfInfo(id);
  const annotations =
    usePdfAnnotations(id).annotations?.filter(
      (a) => a.page_index === pageIndex,
    ) || [];

  const currentToolbar = usePdfViewerStore((state) => state.states[id].tool);
  const setSidebar = usePdfViewerStore((state) => state.setSidebar);
  const { setQuery, search } = useDictionaryStore();

  const onTextSelected = (selectedText: string) => {
    if (currentToolbar !== "dictionary") return;
    setQuery(id, selectedText);
    search(id, selectedText);
    setSidebar(id, SidebarPanel.Dictionary);
  };

  if (!info) {
    return (
      <Center mb={16}>
        <Loader />
      </Center>
    );
  }

  // =============================
  // 🔥 SINGLE SOURCE OF TRUTH SCALE
  // =============================

  const dpr = window.devicePixelRatio || 1;

  // CSS display width
  const displayWidth = width / dpr;

  // PDF page size in points
  const pdfWidth = pageWidth ?? info.width;
  const pdfHeight = info.height;

  // Render pixel dimensions (Rust target_width MUST match this)
  const renderWidth = Math.floor(displayWidth * dpr);
  const renderHeight = Math.floor(renderWidth * (pdfHeight / pdfWidth));

  // CSS display height
  const displayHeight = renderHeight / dpr;

  // Text / annotation scale
  const scale = displayWidth / pdfWidth;

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
          overflow: "hidden",
        }}
      >
        {/* 🔥 TILE LAYER (bitmap rendering will go here) */}
        <TileLayer
          id={id}
          pageIndex={pageIndex}
          renderWidth={renderWidth}
          renderHeight={renderHeight}
          dpr={dpr}
        />

        {/* Annotation Layer */}
        {annotations && (
          <AnnotationLayer
            annotations={annotations}
            scale={scale}
            width={displayWidth}
            height={displayHeight}
          />
        )}

        {/* Text Layer */}
        {textItems && (
          <TextLayer
            textItems={textItems}
            scale={scale}
            width={displayWidth}
            height={displayHeight}
            onTextSelected={onTextSelected}
          />
        )}

        {/* Search Highlights */}
        <SearchHighlightLayer id={id} pageIndex={pageIndex} scale={scale} />
      </Box>
    </Box>
  );
}
