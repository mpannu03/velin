import { JSX, useEffect, useRef, useState } from "react";
import { Box, Center, Loader } from "@mantine/core";
import { usePdfInfo, usePdfPage, usePdfText } from "../hooks";
import { TextLayer, SearchHighlightLayer, AnnotationLayer, SelectionMenu } from "./";
import { SidebarPanel, usePdfViewerStore, useDictionaryStore, useAnnotationsStore } from "../stores";
import { Annotation, AnnotationType, Quad } from "../types";

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

    const [selection, setSelection] = useState<{
        text: string;
        rects: DOMRect[];
        menuPosition: { x: number; y: number };
    } | null>(null);

    const { annotations, fetchAnnotations, addAnnotation } = useAnnotationsStore();
    const pageAnnotations = (annotations[id] || []).filter(a => a.page_index === pageIndex);

    useEffect(() => {
        if (isVisible) {
            fetchAnnotations(id);
        }
    }, [id, isVisible, fetchAnnotations]);

  const onTextSelected = (selectedText: string, rects: DOMRect[]) => {
    if (currentToolbar === "dictionary") {
        setQuery(id, selectedText);
        search(id, selectedText);
        setSidebar(id, SidebarPanel.Dictionary);
        return;
    }

    // Calculate menu position (centered above selection)
    if (rects.length > 0) {
        const first = rects[0];
        setSelection({
            text: selectedText,
            rects,
            menuPosition: { x: first.left + first.width / 2, y: first.top },
        });
    }
  };

  const handleHighlight = async () => {
    if (!selection) return;

    // Convert DOMRects to PdfRect union or just use bounding box for now
    // Ideally we want to support multiple quads (highlights can be multi-line)
    // For now, simpler approach: bounding box of all rects in page coordinates

    // We need to convert from client coordinates to relative to the PDF Page container
    const container = canvasRef.current?.parentElement;
    if (!container) return;

    const containerRect = container.getBoundingClientRect();
    
    // We should compute the union of all selection rects relative to container.
    // However, `Annotation` struct currently has ONE `rect`.
    // Multi-line highlights usually require `QuadPoints` which I haven't fully implemented in backend yet.
    // My previous backend implementation was generating error for Highlight creation.
    // I need to fix that backend side if I want this to work fully.
    // But for frontend, I will send the bounding box.

    let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;

    selection.rects.forEach(r => {
        minX = Math.min(minX, r.left);
        minY = Math.min(minY, r.top);
        maxX = Math.max(maxX, r.right);
        maxY = Math.max(maxY, r.bottom);
    });

    const left = (minX - containerRect.left) / scale;
    const top = (minY - containerRect.top) / scale;
    const right = (maxX - containerRect.left) / scale;
    const bottom = (maxY - containerRect.top) / scale;

    const quads: Quad[] = selection.rects.map(r => ({
        p1: { x: (r.left - containerRect.left) / scale, y: (r.bottom - containerRect.top) / scale },
        p2: { x: (r.right - containerRect.left) / scale, y: (r.bottom - containerRect.top) / scale },
        p3: { x: (r.right - containerRect.left) / scale, y: (r.top - containerRect.top) / scale },
        p4: { x: (r.left - containerRect.left) / scale, y: (r.top - containerRect.top) / scale },
    }));

    const newAnnotation: Annotation = {
        id: crypto.randomUUID(),
        page_index: pageIndex,
        subtype: AnnotationType.Highlight,
        rect: { left, top, right, bottom },
        geometry: { type: "quadpoints", data: quads },
        appearance: {
            color: "#FFFF00",
            opacity: 0.3,
        },
        metadata: {
            author: "User",
            contents: selection.text,
            creation_date: new Date().toISOString(),
        },
        flags: {
            hidden: false,
            locked: false,
            printable: true,
            read_only: false,
        },
    };

    await addAnnotation(id, newAnnotation);
    setSelection(null);
    window.getSelection()?.removeAllRanges();
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
        onMouseDown={() => setSelection(null)} // Click outside to close menu
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
        {pageAnnotations.length > 0 && (
            <AnnotationLayer 
                annotations={pageAnnotations}
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
          <SearchHighlightLayer
            id={id}
            pageIndex={pageIndex}
            scale={scale}
          />
        )}
      </Box>
      {selection && (
        <SelectionMenu
            x={selection.menuPosition.x}
            y={selection.menuPosition.y}
            onHighlight={handleHighlight}
            onDictionary={() => {
                setQuery(id, selection.text);
                search(id, selection.text);
                setSidebar(id, SidebarPanel.Dictionary);
                setSelection(null);
            }}
            onCopy={() => {
                navigator.clipboard.writeText(selection.text);
                setSelection(null);
            }}
            onClose={() => setSelection(null)}
        />
      )}
    </Box>
  );
}
