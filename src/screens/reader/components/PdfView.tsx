import { JSX, useEffect, useRef } from "react";
import { Center, Loader } from "@mantine/core";
import { useVirtualizer } from "@tanstack/react-virtual";
import { useDocumentsStore, useDocumentRepositoryStore } from "@/app";
import { PdfDocument } from "@/shared/types";
import {
  usePdfInfo,
  usePdfWheelZoom,
  useCurrentPageFromVirtual,
} from "../hooks";
import { usePdfViewerStore } from "../stores";
import { PdfPage, ToolsPanel, SidePanel, SideBarPanel } from "./";
import { pdfRenderQueue } from "../renderer";
import { useViewportSize } from "@mantine/hooks";

type PdfViewProps = {
  doc: PdfDocument;
};

export function PdfView({ doc }: PdfViewProps): JSX.Element {
  const id: string = doc.id;
  const activeDocumentId = useDocumentsStore().activeDocumentId;
  const { info, error, loading } = usePdfInfo(id);
  const parentRef = useRef<HTMLDivElement>(null);
  const viewerState = usePdfViewerStore().getState(id);
  const wheelRef = usePdfWheelZoom(id);
  const gotoPage = usePdfViewerStore().getState(id).gotoPage;
  const clearGotoPage = usePdfViewerStore().clearGotoPage;
  const currentPage = useDocumentRepositoryStore().getDocumentByFilePath(
    doc.filePath,
  );

  const baseWidth = useViewportSize().width / 2;
  const displayWidth = baseWidth * viewerState.scale;

  const dpr = window.devicePixelRatio || 1;
  const renderWidth = Math.floor(displayWidth * dpr);

  const aspectRatio =
    info?.height && info?.width && info.width > 0
      ? info.height / info.width
      : 1.414;

  const estimatedHeight = (renderWidth * aspectRatio) / dpr + 16;

  const rowVirtualizer = useVirtualizer({
    count: info?.page_count ?? 0,
    getScrollElement: () => parentRef.current,
    estimateSize: () => estimatedHeight,
    overscan: 3,
    scrollMargin: 16,
  });

  const measureRaf = useRef<number | null>(null);

  useEffect(() => {
    if (measureRaf.current) cancelAnimationFrame(measureRaf.current);

    measureRaf.current = requestAnimationFrame(() => {
      rowVirtualizer.measure();
    });

    return () => {
      if (measureRaf.current) cancelAnimationFrame(measureRaf.current);
    };
  }, [estimatedHeight, rowVirtualizer]);

  useEffect(() => {
    if (gotoPage == null) return;

    rowVirtualizer.scrollToIndex(gotoPage, {
      align: "start",
    });

    pdfRenderQueue.clear();
    clearGotoPage(id);
  }, [gotoPage, rowVirtualizer, clearGotoPage, id]);

  const initialScrollDone = useRef(false);

  useEffect(() => {
    if (loading || !info || !currentPage || initialScrollDone.current) return;

    if (currentPage.currentPage > 0) {
      setTimeout(() => {
        rowVirtualizer.scrollToIndex(currentPage.currentPage, {
          align: "start",
        });
      }, 0);
    }
    initialScrollDone.current = true;
  }, [info, loading, currentPage, rowVirtualizer]);

  useCurrentPageFromVirtual({
    virtualizer: rowVirtualizer,
    id,
  });

  if (loading) {
    return (
      <Center h="100%">
        <Loader />
      </Center>
    );
  }

  if (error) {
    return <div>Loading Error: {error}</div>;
  }

  if (!info) {
    return <div>Loading PDF info...</div>;
  }

  return (
    <div
      ref={wheelRef}
      style={{
        display: "flex",
        flexDirection: "row",
        background:
          "light-dark(var(--mantine-color-gray-1), var(--mantine-color-dark-6))",
        visibility: activeDocumentId === id ? "visible" : "hidden",
        position: activeDocumentId === id ? "relative" : "absolute",
        top: 0,
        left: 0,
        width: "100%",
        height: "100%",
        pointerEvents: activeDocumentId === id ? "auto" : "none",
      }}
    >
      <ToolsPanel documentId={id} />
      <div
        ref={parentRef}
        id="pdf-scroll-container"
        style={{
          flex: 1,
          overflow: "auto",
          cursor:
            viewerState.tool === "hand"
              ? "grab"
              : viewerState.tool === "dictionary"
                ? "default"
                : "default",
        }}
      >
        <div
          style={{
            height: `${rowVirtualizer.getTotalSize()}px`,
            minWidth: `${displayWidth}px`,
            position: "relative",
            contain: "strict",
            willChange: "transform",
          }}
        >
          {rowVirtualizer.getVirtualItems().map((virtualItem) => (
            <div
              key={virtualItem.key}
              data-index={virtualItem.index}
              style={{
                position: "absolute",
                top: 0,
                left: 0,
                width: "100%",
                transform: `translateY(${virtualItem.start}px)`,
                display: "flex",
                justifyContent: "center",
              }}
            >
              <PdfPage
                id={id}
                pageIndex={virtualItem.index}
                width={renderWidth}
                dpr={dpr}
                isVisible={virtualItem.index === viewerState.currentPage}
                isScrolling={rowVirtualizer.isScrolling}
              />
            </div>
          ))}
        </div>
      </div>

      <SidePanel id={id} />
      <SideBarPanel documentId={id} />
    </div>
  );
}
