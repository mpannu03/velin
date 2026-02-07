import { JSX } from "react";
import { TextItem } from "@/shared/types";
import { Box } from "@mantine/core";

export type TextLayerProps = {
  textItems: TextItem[];
  scale: number;
  width: number;
  height: number;
};

export function TextLayer({ textItems, scale, width, height }: TextLayerProps): JSX.Element {
  return (
    <Box
      className="text-layer"
      style={{
        position: "absolute",
        top: 0,
        left: 0,
        width: `${width}px`,
        height: `${height}px`,
        pointerEvents: "auto",
        userSelect: "text",
        overflow: "hidden",
        lineHeight: 1,
      }}
    >
      <style>{`
        .text-layer span::selection {
          background: rgba(0, 102, 255, 0.3);
          color: transparent;
        }
      `}</style>
      {textItems.map((item, index) => (
        <span
          key={index}
          style={{
            position: "absolute",
            left: `${item.x * scale}px`,
            top: `${item.y * scale}px`,
            width: `${item.width * scale}px`,
            height: `${item.height * scale}px`,
            fontSize: `${item.height * scale}px`,
            fontFamily: "sans-serif",
            color: "transparent",
            display: "inline-block",
            pointerEvents: "auto",
            lineHeight: 1,
            whiteSpace: "nowrap",
          }}
        >
          {item.text}
        </span>
      ))}
    </Box>
  );
}
