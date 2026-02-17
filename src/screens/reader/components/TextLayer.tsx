import { JSX, memo } from "react";
import { TextItem } from "@/shared/types";

export type TextLayerProps = {
  textItems: TextItem[];
  scale: number;

  width: number;
  height: number;

  onTextSelected?: (selectedText: string) => void;
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
  // Pre-calculate approximate scaleX based on target width
  // This avoids expensive getBoundingClientRect and useLayoutEffect
  // The browser's font rendering naturally handles most of the alignment
  const targetWidth = item.width * scale;
  const approximateFontWidth = item.text.length * item.height * scale * 0.5;
  const scaleX = approximateFontWidth > 0 ? targetWidth / approximateFontWidth : 1;

  return (
    <span
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
        const selected = window.getSelection()?.toString().trim();
        if (selected) {
          onTextSelected?.(selected);
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