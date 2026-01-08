import { JSX } from "react";
import { PdfPage } from './PdfPage';
import { useDocumentsStore } from "@/app";
import { usePdfInfo } from "../hooks/usePdfInfo";
import { Loader } from "@mantine/core";
import { useViewportSize } from "@mantine/hooks";

type PdfViewProps = {
  id: string;
};

import { useRef } from "react";
import { useVirtualizer } from '@tanstack/react-virtual';

export function PdfView({ id }: PdfViewProps): JSX.Element {
  const activeDocumentId = useDocumentsStore((s) => s.activeDocumentId);
  const { info, error, loading } = usePdfInfo(id);
  /* ------------------ Sizing Logic ------------------ */
  const { width: windowWidth } = useViewportSize();

  // 1/3 of window width logic (with min safety)
  const displayWidth = Math.max(windowWidth / 3, 400);
  const renderWidth = displayWidth * 2; // Request 2x resolution for High DPI

  // Aspect ratio fallback to standard A4 (1 / 1.414)
  const aspectRatio = (info?.height && info?.width)
    ? (info.height / info.width)
    : 1.414;

  const estimatedHeight = displayWidth * aspectRatio;

  const parentRef = useRef<HTMLDivElement>(null);

  const rowVirtualizer = useVirtualizer({
    count: info?.page_count ?? 0,
    getScrollElement: () => parentRef.current,
    estimateSize: () => estimatedHeight,
    overscan: 3,
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
      ref={parentRef}
      id="pdf-scroll-container"
      style={{
        height: "100vh",
        overflow: "auto",
        padding: "16px 16px 92px 16px",
        display: activeDocumentId === id ? 'block' : 'none',
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
            }}
          >
            <PdfPage
              id={id}
              pageIndex={virtualItem.index}
              width={renderWidth}
            />
          </div>
        ))}
      </div>
    </div>
  );
};