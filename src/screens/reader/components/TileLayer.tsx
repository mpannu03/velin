import { useEffect, useMemo, useRef, useState, memo } from "react";
import { usePdfPage, usePdfTile } from "../hooks";

const TILE_SIZE = 256;
const OVERSCAN_PAGES = 1.0;

type Props = {
  id: string;
  pageIndex: number;
  renderWidth: number;
  renderHeight: number;
  dpr: number;
  isScrolling?: boolean;
};

export function TileLayer({
  id,
  pageIndex,
  renderWidth,
  renderHeight,
  dpr,
  isScrolling,
}: Props) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [visibleRange, setVisibleRange] = useState({
    startY: 0,
    endY: TILE_SIZE * dpr,
    viewportTop: 0,
    viewportBottom: window.innerHeight,
  });

  const lowResWidth = Math.min(renderWidth, 512);
  const { page: lowResPage } = usePdfPage(id, pageIndex, lowResWidth);

  useEffect(() => {
    let rafId: number;
    const update = () => {
      if (!containerRef.current) return;

      const rect = containerRef.current.getBoundingClientRect();

      const scrollContainer = document.getElementById("pdf-scroll-container");
      const viewportHeight = scrollContainer
        ? scrollContainer.clientHeight
        : window.innerHeight;

      const viewportTop = -rect.top;
      const viewportBottom = viewportHeight - rect.top;

      const overscan = viewportHeight * OVERSCAN_PAGES;
      const visibleTop = Math.max(0, viewportTop - overscan);
      const visibleBottom = Math.min(rect.height, viewportBottom + overscan);

      const startY = Math.floor((visibleTop * dpr) / TILE_SIZE) * TILE_SIZE;
      const endY = Math.ceil((visibleBottom * dpr) / TILE_SIZE) * TILE_SIZE;

      const nextStartY = Math.round(startY);
      const nextEndY = Math.round(endY);

      setVisibleRange((prev) => {
        const boundsChanged =
          prev.startY !== nextStartY || prev.endY !== nextEndY;
        const viewportShifted =
          Math.abs(prev.viewportTop - viewportTop) > 10 ||
          Math.abs(prev.viewportBottom - viewportBottom) > 10;

        if (!boundsChanged && !viewportShifted) {
          return prev;
        }

        return {
          startY: nextStartY,
          endY: nextEndY,
          viewportTop,
          viewportBottom,
        };
      });
    };

    const onScroll = () => {
      cancelAnimationFrame(rafId);
      rafId = requestAnimationFrame(update);
    };

    onScroll();
    const scrollContainer = document.getElementById("pdf-scroll-container");
    const target = scrollContainer || window;

    target.addEventListener("scroll", onScroll, { passive: true });
    window.addEventListener("resize", onScroll, { passive: true });

    return () => {
      cancelAnimationFrame(rafId);
      target.removeEventListener("scroll", onScroll);
      window.removeEventListener("resize", onScroll);
    };
  }, [dpr, renderWidth, renderHeight]);

  const tiles = useMemo(() => {
    const result = [];

    for (let y = visibleRange.startY; y < visibleRange.endY; y += TILE_SIZE) {
      if (y >= renderHeight) break;
      for (let x = 0; x < renderWidth; x += TILE_SIZE) {
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
      {lowResPage && (
        <LowResFallback
          pixels={lowResPage.pixels}
          width={lowResPage.width}
          height={lowResPage.height}
        />
      )}

      {tiles.map((tile) => {
        // Skip hi-res rendering while scrolling fast
        if (isScrolling) return null;

        const isVisible =
          tile.y + tile.height > visibleRange.viewportTop * dpr &&
          tile.y < visibleRange.viewportBottom * dpr;
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

const TileCanvas = memo(
  ({ id, pageIndex, renderWidth, tile, dpr, priority }: any) => {
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

      if (canvas.width !== tile.width || canvas.height !== tile.height) {
        canvas.width = tile.width;
        canvas.height = tile.height;
      }

      const ctx = canvas.getContext("2d", { alpha: false });

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
  },
  (prev, next) => {
    return (
      prev.id === next.id &&
      prev.pageIndex === next.pageIndex &&
      prev.renderWidth === next.renderWidth &&
      prev.priority === next.priority &&
      prev.tile.x === next.tile.x &&
      prev.tile.y === next.tile.y &&
      prev.tile.width === next.tile.width &&
      prev.tile.height === next.tile.height
    );
  },
);
