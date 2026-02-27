import { JSX, useEffect, useRef } from "react";
import { Center, Loader } from "@mantine/core";
import { useViewportSize } from "@mantine/hooks";
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

type PdfViewProps = {
  doc: PdfDocument;
};

export function PdfView({ doc }: PdfViewProps): JSX.Element {
  const id: string = doc.id;
  const activeDocumentId = useDocumentsStore((s) => s.activeDocumentId);
  const { info, error, loading } = usePdfInfo(id);
  const parentRef = useRef<HTMLDivElement>(null);
  const viewerState = usePdfViewerStore((s) => s.getState(id));
  const wheelRef = usePdfWheelZoom(id);
  const gotoPage = usePdfViewerStore((s) => s.getState(id).gotoPage);
  const clearGotoPage = usePdfViewerStore((s) => s.clearGotoPage);
  const currentPage = useDocumentRepositoryStore((s) =>
    s.getDocumentByFilePath(doc.filePath),
  );

  const { width: windowWidth } = useViewportSize();

  const baseWidth = Math.max(windowWidth / 2, 400);
  const displayWidth = baseWidth * viewerState.scale;
  // const renderWidth = displayWidth * 2;

  const dpr = window.devicePixelRatio || 1;
  const renderWidth = Math.floor(displayWidth * dpr);

  const aspectRatio =
    info?.height && info?.width ? info.height / info.width : 1.414;

  const estimatedHeight = displayWidth * aspectRatio;

  const rowVirtualizer = useVirtualizer({
    count: info?.page_count ?? 0,
    getScrollElement: () => parentRef.current,
    estimateSize: () => estimatedHeight,
    overscan: 3,
    scrollMargin: 16,
  });

  useEffect(() => {
    if (gotoPage == null) return;

    rowVirtualizer.scrollToIndex(gotoPage, {
      align: "start",
    });

    clearGotoPage(id);
  }, [gotoPage, rowVirtualizer, clearGotoPage]);

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
            width: "100%",
            position: "relative",
          }}
        >
          {rowVirtualizer.getVirtualItems().map((virtualItem) => (
            <div
              key={virtualItem.key}
              data-index={virtualItem.index}
              ref={rowVirtualizer.measureElement}
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
                aspectRatio={aspectRatio}
                isVisible={virtualItem.index === viewerState.currentPage}
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
