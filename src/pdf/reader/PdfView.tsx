import { JSX, useEffect, useRef, useState } from "react";
import { Center, Loader } from "@mantine/core";
import { useVirtualizer } from "@tanstack/react-virtual";
import { PdfDocument } from "@/shared/types";
import {
  usePdfInfo,
  usePdfWheelZoom,
  useCurrentPageFromVirtual,
} from "./hooks";
import { usePdfViewerStore } from "./stores";
import { PdfPage, ToolsPanel, SidePanel, SideBarPanel } from "./components";
import { pdfRenderQueue } from "./renderer";
import { useViewportSize } from "@mantine/hooks";
import { useDocumentRepositoryStore } from "@/app";
import { useTranslation } from "react-i18next";

type PdfViewProps = {
  doc: PdfDocument;
  activeDocumentId: string | null;
};

/**
 * Delay (ms) before "committing" a zoom — re-rendering tiles at the new
 * resolution. During this window, a CSS scale transform provides smooth,
 * instant visual feedback.
 */
const ZOOM_COMMIT_DELAY_MS = 300;

export function PdfView({ doc, activeDocumentId }: PdfViewProps): JSX.Element {
  const { t } = useTranslation("reader");
  const id: string = doc.id;
  const { info, error, loading } = usePdfInfo(id);
  const parentRef = useRef<HTMLDivElement>(null);
  const viewerState = usePdfViewerStore().getState(id);
  const wheelRef = usePdfWheelZoom(id);
  const gotoPage = usePdfViewerStore().getState(id).gotoPage;
  const clearGotoPage = usePdfViewerStore().clearGotoPage;
  const currentPage = useDocumentRepositoryStore().getDocumentByFilePath(
    doc.filePath,
  )?.currentPage;

  // ===== Smooth Zoom State =====
  // renderingScale – the resolution at which tiles are currently painted
  const [renderingScale, setRenderingScale] = useState(viewerState.scale);
  const [isZooming, setIsZooming] = useState(false);
  const zoomTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

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

  // ---- Smooth zoom effect ----
  useEffect(() => {
    const targetScale = viewerState.scale;

    // If scales are effectively equal, no transition needed
    if (Math.abs(targetScale - renderingScale) < 0.01) {
      setIsZooming(false);
      return;
    }

    // Start CSS transform transition immediately for smooth feedback
    setIsZooming(true);

    // Clear any pending commit
    if (zoomTimerRef.current) {
      clearTimeout(zoomTimerRef.current);
    }

    // After a delay, "commit" the zoom — update rendering scale so tiles
    // re-render at the target resolution. The CSS transform ratio will be 1,
    // so no visible jump occurs.
    zoomTimerRef.current = setTimeout(() => {
      setRenderingScale(targetScale);
      setIsZooming(false);

      // Re-measure virtualizer with new page heights
      cancelAnimationFrame(measureRaf.current ?? 0);
      measureRaf.current = requestAnimationFrame(() => {
        rowVirtualizer.measure();
      });
    }, ZOOM_COMMIT_DELAY_MS);
  }, [viewerState.scale, renderingScale, rowVirtualizer]);

  // CSS scale factor: scales existing tiles to match the target display size
  const zoomRatio =
    isZooming && renderingScale > 0 ? viewerState.scale / renderingScale : 1;

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

    if (currentPage > 0) {
      setTimeout(() => {
        rowVirtualizer.scrollToIndex(currentPage, {
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

  // Clean up zoom timer on unmount
  useEffect(() => {
    return () => {
      if (zoomTimerRef.current) clearTimeout(zoomTimerRef.current);
    };
  }, []);

  if (loading) {
    return (
      <Center h="100%">
        <Loader />
      </Center>
    );
  }

  if (error) {
    return (
      <div>
        {t("error.loading")} {error}
      </div>
    );
  }

  if (!info) {
    return <div>{t("loading.info")}</div>;
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
            willChange: isZooming ? "transform" : "auto",
            transform: isZooming ? `scale(${zoomRatio})` : undefined,
            transformOrigin: "top left",
            transition: isZooming ? "transform 0.1s ease-out" : undefined,
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
