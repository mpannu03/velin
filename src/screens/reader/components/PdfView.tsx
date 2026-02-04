import { JSX, useEffect, useRef } from "react";
import { Loader } from "@mantine/core";
import { useViewportSize } from "@mantine/hooks";
import { useVirtualizer } from '@tanstack/react-virtual';
import { useDocumentsStore } from "@/app";
import { usePdfInfo } from "../hooks/usePdfInfo";
import { usePdfViewerStore } from "../stores/pdf_viewer.store";
import { PdfPage } from './PdfPage';
import { ReaderToolbar } from "./ReaderToolbar";
import { SidePanel } from "./SidePanel";
import { useCurrentPageFromVirtual, usePdfWheelZoom } from "../hooks";

type PdfViewProps = {
  id: string;
};

export function PdfView({ id }: PdfViewProps): JSX.Element {
  const activeDocumentId = useDocumentsStore((s) => s.activeDocumentId);
  const { info, error, loading } = usePdfInfo(id);
  const parentRef = useRef<HTMLDivElement>(null);
  const viewerState = usePdfViewerStore(s => s.getState(id));
  const wheelRef = usePdfWheelZoom(id);
  const gotoPage = usePdfViewerStore((s) => s.getState(id).gotoPage);
  const clearGotoPage = usePdfViewerStore(s => s.clearGotoPage);

  const { width: windowWidth } = useViewportSize();

  const baseWidth = Math.max(windowWidth / 2, 400);
  const displayWidth = baseWidth * viewerState.scale;
  const renderWidth = displayWidth * 2;

  const aspectRatio = (info?.height && info?.width)
    ? (info.height / info.width)
    : 1.414;

  const estimatedHeight = displayWidth * aspectRatio;

  const rowVirtualizer = useVirtualizer({
    count: info?.page_count ?? 0,
    getScrollElement: () => parentRef.current,
    estimateSize: () => estimatedHeight,
    overscan: 3,
    scrollMargin: 16
  });

  useEffect(() => {
    if (gotoPage == null) return;

    rowVirtualizer.scrollToIndex(gotoPage, {
      align: "start",
    });

    clearGotoPage(id);
  }, [gotoPage, id, rowVirtualizer, clearGotoPage]);

  useCurrentPageFromVirtual({
    virtualizer: rowVirtualizer,
    id,
  });

  if (loading) {
    return <Loader />
  }

  if (error) {
    return <div>Loading Error: {error}</div>
  }

  if (!info) {
    return <div>Loading PDF info...</div>;
  }

  return (
    <div
      ref={wheelRef}
      style={{
        display: "flex",
        flexDirection: 'row',
        backgroundColor: '#f1f3f5',
        visibility: activeDocumentId === id ? 'visible' : 'hidden',
        position: activeDocumentId === id ? 'relative' : 'absolute',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        pointerEvents: activeDocumentId === id ? 'auto' : 'none',
      }}
    >
      <div
        ref={parentRef}
        id="pdf-scroll-container"
        style={{
          flex: 1,
          overflow: "auto",
          padding: "16px",
          cursor: viewerState.tool === 'hand' ? 'grab' : 'default',
        }}
      >
        <div
          style={{
            height: `${rowVirtualizer.getTotalSize()}px`,
            width: '100%',
            position: 'relative',
          }}
        >
          {rowVirtualizer.getVirtualItems().map((virtualItem) => (
            <div
              key={virtualItem.key}
              data-index={virtualItem.index}
              ref={rowVirtualizer.measureElement}
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: '100%',
                transform: `translateY(${virtualItem.start}px)`,
                display: 'flex',
                justifyContent: 'center',
              }}
            >
              <PdfPage
                id={id}
                pageIndex={virtualItem.index}
                width={renderWidth}
                aspectRatio={aspectRatio}
              />
            </div>
          ))}
        </div>
      </div>

      <SidePanel id={id} />
      <ReaderToolbar documentId={id} />
    </div>
  );
};
