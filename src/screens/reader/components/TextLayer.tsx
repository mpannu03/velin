import { JSX, memo, useLayoutEffect, useRef, useState } from "react";
import { TextItem } from "@/shared/types";

export type TextLayerProps = {
  textItems: TextItem[];
  scale: number;

  width: number;
  height: number;

  onTextSelected?: (selectedText: string, rects: DOMRect[]) => void;
};

/**
 * Grouped text fragment (memoized for performance)
 */
const TextFragment = memo(function TextFragment({
  item,
  scale,
}: {
  item: TextItem;
  scale: number;
}) {
  const ref = useRef<HTMLSpanElement>(null);
  const [scaleX, setScaleX] = useState(1);

  useLayoutEffect(() => {
    if (ref.current) {
      const naturalWidth = ref.current.getBoundingClientRect().width;
      const targetWidth = item.width * scale;
      if (naturalWidth > 0 && Math.abs(naturalWidth - targetWidth) > 0.1) {
        setScaleX(targetWidth / naturalWidth);
      }
    }
  }, [item.text, item.width, scale]);

  return (
    <span
      ref={ref}
      className="text-fragment"
      style={{
        position: "absolute",
        left: item.x * scale,
        top: item.y * scale,
        fontSize: item.height * scale,
        fontFamily: "sans-serif",
        lineHeight: 1,
        whiteSpace: "pre",
        color: "transparent",
        pointerEvents: "auto",
        transformOrigin: "left top",
        transform: `scaleX(${scaleX})`,
      }}
    >
      {item.text}
    </span>
  );
});

/**
 * Selectable PDF text layer (fragment-based, high performance)
 */
export function TextLayer({
  textItems,
  scale,
  width,
  height,
  onTextSelected,
}: TextLayerProps): JSX.Element {
  return (
    <div
      className="text-layer"
      onMouseUp={() => {
        const selection = window.getSelection();
        const selected = selection?.toString().trim();
        if (selection && selected && selection.rangeCount > 0) {
          const range = selection.getRangeAt(0);
          const rects = Array.from(range.getClientRects());
          onTextSelected?.(selected, rects);
        }
      }}
      style={{
        position: "absolute",
        top: 0,
        left: 0,
        width: width * scale,
        height: height * scale,
        pointerEvents: "none",
        userSelect: "text",
        cursor: "text",
      }}
    >
      {/* Professional selection styling */}
      <style>{`
        .text-layer {
          mix-blend-mode: multiply;
        }
        .text-layer::selection {
          background: rgba(0, 102, 255, 0.2);
        }
        .text-layer .text-fragment::selection {
          background: rgba(0, 102, 255, 0.2);
          color: transparent;
        }
        .text-fragment {
            pointer-events: auto;
        }
      `}</style>

      {textItems.map((item, index) => (
        <TextFragment key={index} item={item} scale={scale} />
      ))}
    </div>
  );
}
