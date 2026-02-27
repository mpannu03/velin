import { useEffect, useMemo, useRef, useState } from "react";
import { usePdfPage, usePdfTile } from "../hooks";

const TILE_SIZE = 512;
const OVERSCAN_PAGES = 1.0; // Render 100% more than visible area for smooth scrolling

type Props = {
  id: string;
  pageIndex: number;
  renderWidth: number;
  renderHeight: number;
  dpr: number;
};

export function TileLayer({
  id,
  pageIndex,
  renderWidth,
  renderHeight,
  dpr,
}: Props) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [visibleRange, setVisibleRange] = useState({
    startY: 0,
    endY: TILE_SIZE * dpr,
    viewportTop: 0,
    viewportBottom: window.innerHeight,
  });

  // 👇 Tiered Rendering: Fetch low-res version of the entire page
  // We use a fixed low target width (e.g., 256 or 512) for the thumbnail
  const lowResWidth = Math.min(renderWidth, 512);
  const { page: lowResPage } = usePdfPage(id, pageIndex, lowResWidth);

  useEffect(() => {
    const update = () => {
      if (!containerRef.current) return;

      const rect = containerRef.current.getBoundingClientRect();

      const scrollContainer = document.getElementById("pdf-scroll-container");
      const viewportHeight = scrollContainer
        ? scrollContainer.clientHeight
        : window.innerHeight;

      // Viewport bounds relative to the page container
      const viewportTop = -rect.top;
      const viewportBottom = viewportHeight - rect.top;

      // Add overscan
      const overscan = viewportHeight * OVERSCAN_PAGES;
      const visibleTop = Math.max(0, viewportTop - overscan);
      const visibleBottom = Math.min(rect.height, viewportBottom + overscan);

      const startY = Math.floor((visibleTop * dpr) / TILE_SIZE) * TILE_SIZE;
      const endY = Math.ceil((visibleBottom * dpr) / TILE_SIZE) * TILE_SIZE;

      // Final rounding for state stability
      setVisibleRange({
        startY: Math.round(startY),
        endY: Math.round(endY),
        viewportTop,
        viewportBottom,
      });
    };

    update();
    const scrollContainer = document.getElementById("pdf-scroll-container");
    const target = scrollContainer || window;

    target.addEventListener("scroll", update, { passive: true });
    window.addEventListener("resize", update, { passive: true });

    return () => {
      target.removeEventListener("scroll", update);
      window.removeEventListener("resize", update);
    };
  }, [dpr, renderWidth, renderHeight]);

  const tiles = useMemo(() => {
    const result = [];

    for (let y = visibleRange.startY; y < visibleRange.endY; y += TILE_SIZE) {
      if (y >= renderHeight) break;
      for (let x = 0; x < renderWidth; x += TILE_SIZE) {
        // Round dimensions to prevent sub-pixel cache misses
        const width = Math.round(Math.min(TILE_SIZE, renderWidth - x));
        const height = Math.round(Math.min(TILE_SIZE, renderHeight - y));

        result.push({
          x: Math.round(x),
          y: Math.round(y),
          width,
          height,
        });
      }
    }

    return result;
  }, [visibleRange, renderWidth, renderHeight]);

  return (
    <div
      ref={containerRef}
      style={{
        position: "absolute",
        inset: 0,
        backgroundColor: "white",
      }}
    >
      {/* 🚀 Low-res Fallback Layer */}
      {lowResPage && (
        <LowResFallback
          pixels={lowResPage.pixels}
          width={lowResPage.width}
          height={lowResPage.height}
        />
      )}

      {/* 💎 High-res Tile Layer */}
      {tiles.map((tile) => {
        // High priority for tiles strictly within the pixel viewport
        const isVisible =
          tile.y + tile.height > visibleRange.viewportTop &&
          tile.y < visibleRange.viewportBottom;
        const priority = isVisible ? 1000 : 100;

        return (
          <TileCanvas
            key={`${tile.x}-${tile.y}-${renderWidth}`}
            id={id}
            pageIndex={pageIndex}
            renderWidth={renderWidth}
            tile={tile}
            dpr={dpr}
            priority={priority}
          />
        );
      })}
    </div>
  );
}

function LowResFallback({ pixels, width, height }: any) {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d", { alpha: false });
    if (!ctx) return;

    canvas.width = width;
    canvas.height = height;

    const imageData = new ImageData(
      new Uint8ClampedArray(pixels),
      width,
      height,
    );

    createImageBitmap(imageData).then((bitmap) => {
      ctx.drawImage(bitmap, 0, 0);
      bitmap.close();
    });
  }, [pixels, width, height]);

  return (
    <canvas
      ref={canvasRef}
      style={{
        position: "absolute",
        inset: 0,
        width: "100%",
        height: "100%",
        filter: "blur(4px)",
        opacity: 0.5,
        pointerEvents: "none",
      }}
    />
  );
}

function TileCanvas({ id, pageIndex, renderWidth, tile, dpr, priority }: any) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const { tile: renderedTile, loading } = usePdfTile(
    id,
    pageIndex,
    renderWidth,
    tile.x,
    tile.y,
    tile.width,
    tile.height,
    priority,
  );

  useEffect(() => {
    if (!renderedTile || !canvasRef.current) return;

    const canvas = canvasRef.current;

    // Only resize if necessary (prevents flickering/clearing)
    if (canvas.width !== tile.width || canvas.height !== tile.height) {
      canvas.width = tile.width;
      canvas.height = tile.height;
    }

    const ctx = canvas.getContext("2d", { alpha: false });

    // ⚡ SUPER FAST: pixels is already an ImageBitmap from reader.ts
    ctx?.drawImage(renderedTile.pixels as any as ImageBitmap, 0, 0);
  }, [renderedTile, tile]);

  return (
    <canvas
      ref={canvasRef}
      style={{
        position: "absolute",
        left: `${tile.x / dpr}px`,
        top: `${tile.y / dpr}px`,
        width: `${tile.width / dpr}px`,
        height: `${tile.height / dpr}px`,
        opacity: loading ? 0 : 1,
        transition: "opacity 0.2s ease-in-out",
      }}
    />
  );
}
