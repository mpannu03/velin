import { JSX, useEffect, useRef } from "react";
import { Loader, Paper, Stack, Text } from "@mantine/core";
import { useViewportSize } from "@mantine/hooks";
import { useVirtualizer } from '@tanstack/react-virtual';
import { useDocumentsStore } from "@/app";
import { usePdfInfo } from "../hooks/usePdfInfo";
import { usePdfViewerStore } from "../stores/usePdfViewerStore";
import { PdfPage } from './PdfPage';
import { ReaderToolbar } from "./ReaderToolbar";

type PdfViewProps = {
  id: string;
};

export function PdfView({ id }: PdfViewProps): JSX.Element {
  const activeDocumentId = useDocumentsStore((s) => s.activeDocumentId);
  const { info, error, loading } = usePdfInfo(id);
  const parentRef = useRef<HTMLDivElement>(null);
  const viewerState = usePdfViewerStore(s => s.getState(id));

  useEffect(() => {
    const el = parentRef.current;
    if (!el) return;

    const handleWheel = (e: WheelEvent) => {
      if (e.ctrlKey || e.metaKey) {
        e.preventDefault();
        const ZOOM_STEPS = [0.1, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0, 5.0];
        if (e.deltaY < 0) {
          const nextStep = ZOOM_STEPS.find(s => s > viewerState.scale) || 5.0;
          usePdfViewerStore.getState().setScale(id, nextStep);
        } else {
          const prevStep = [...ZOOM_STEPS].reverse().find(s => s < viewerState.scale) || 0.1;
          usePdfViewerStore.getState().setScale(id, prevStep);
        }
      }
    };

    el.addEventListener('wheel', handleWheel, { passive: false });
    return () => el.removeEventListener('wheel', handleWheel);
  }, [id, viewerState.scale]);

  /* ------------------ Sizing Logic ------------------ */
  const { width: windowWidth } = useViewportSize();

  // 1/3 of window width logic (with min safety) * ZOOM SCALE
  const baseWidth = Math.max(windowWidth / 3, 400);
  const displayWidth = baseWidth * viewerState.scale;
  const renderWidth = displayWidth * 2; // Request 2x resolution for High DPI

  // Aspect ratio fallback to standard A4 (1 / 1.414)
  const aspectRatio = (info?.height && info?.width)
    ? (info.height / info.width)
    : 1.414;

  const estimatedHeight = displayWidth * aspectRatio;

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
      style={{
        display: "flex",
        flexDirection: 'row',
        backgroundColor: '#f1f3f5',
        // Hiding logic: use visibility and absolute positioning to preserve scroll state
        visibility: activeDocumentId === id ? 'visible' : 'hidden',
        position: activeDocumentId === id ? 'relative' : 'absolute',
        top: 0,
        left: 0,
        width: '100%',
        height: '100vh',
        pointerEvents: activeDocumentId === id ? 'auto' : 'none',
      }}
    >
      {/* Scrollable PDF Content */}
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
              />
            </div>
          ))}
        </div>
      </div>

      {/* Sidebar Panel Content (e.g. Bookmarks/Comments list) */}
      {viewerState.sidebar !== 'none' && (
        <Paper
          w={250}
          h="100%"
          p="md"
          withBorder
          style={{
            borderTop: 0,
            borderBottom: 0,
            backgroundColor: 'var(--mantine-color-body)',
          }}
        >
          <Stack gap="sm">
            <Text fw={700} tt="uppercase" size="xs" c="dimmed">
              {viewerState.sidebar}
            </Text>
            <Text size="sm" c="dimmed" fs="italic">
              No {viewerState.sidebar} yet.
            </Text>
          </Stack>
        </Paper>
      )}

      {/* Right Sidebar Toolbar */}
      <ReaderToolbar documentId={id} />

      {/* Scroll Position Sync (Fallback & State persistence) */}
      {activeDocumentId === id && (
        <ScrollSync 
          id={id} 
          active={true} 
          parentRef={parentRef} 
          scrollOffset={viewerState.scrollOffset}
        />
      )}
    </div>
  );
};

function ScrollSync({ 
  id, 
  active, 
  parentRef, 
  scrollOffset 
}: { 
  id: string; 
  active: boolean; 
  parentRef: React.RefObject<HTMLDivElement | null>;
  scrollOffset: number;
}) {
  const setScrollOffset = usePdfViewerStore(s => s.setScrollOffset);

  // Restore scroll only once on mount if it's different
  useEffect(() => {
    if (active && parentRef.current && Math.abs(parentRef.current.scrollTop - scrollOffset) > 1) {
      parentRef.current.scrollTop = scrollOffset;
    }
  }, []); // Only on mount of ScrollSync (which happens when tab becomes active)

  // Periodic save while active
  useEffect(() => {
    if (!active || !parentRef.current) return;

    const el = parentRef.current;
    let frameId: number;

    const handleScroll = () => {
      cancelAnimationFrame(frameId);
      frameId = requestAnimationFrame(() => {
        setScrollOffset(id, el.scrollTop);
      });
    };

    el.addEventListener('scroll', handleScroll, { passive: true });
    return () => {
      el.removeEventListener('scroll', handleScroll);
      cancelAnimationFrame(frameId);
    };
  }, [active, id, setScrollOffset]);

  return null;
}
