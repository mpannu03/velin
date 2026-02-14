import { JSX, memo } from "react";
import { useSearchStore } from "../stores";

type SearchHighlightLayerProps = {
  id: string;
  pageIndex: number;
  scale: number;
};

export const SearchHighlightLayer = memo(function SearchHighlightLayer({
  id,
  pageIndex,
  scale,
}: SearchHighlightLayerProps): JSX.Element | null {
  const result = useSearchStore((s) => s.results[id]);
  const currentIndex = useSearchStore((s) => s.currentIndex);

  const pageHits = result?.filter((hit) => hit.page === pageIndex) ?? [];

  if (pageHits.length === 0) return null;

  return (
    <div
      className="search-highlight-layer"
      style={{
        position: "absolute",
        top: 0,
        left: 0,
        width: "100%",
        height: "100%",
        pointerEvents: "none",
        mixBlendMode: "multiply",
      }}
    >
      {pageHits.map((hit, hitIndex) => {
        const isCurrent = result.indexOf(hit) === currentIndex;
        return hit.rects.map((rect, rectIndex) => (
          <div
            key={`${hitIndex}-${rectIndex}`}
            style={{
              position: "absolute",
              left: rect.x * scale,
              top: rect.y * scale,
              width: rect.w * scale,
              height: rect.h * scale,
              backgroundColor: isCurrent ? "rgba(255, 255, 0, 0.5)" : "rgba(255, 255, 0, 0.3)",
              border: isCurrent ? "1px solid orange" : "none",
            }}
          />
        ));
      })}
    </div>
  );
});
