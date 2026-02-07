import { JSX } from "react";
import { TextItem } from "@/shared/types";
import { Box } from "@mantine/core";

export type TextLayerProps = {
  textItems: TextItem[];
  scale: number;
  width: number;
  height: number;
};

// Helper to measure text width without rendering
const measureTextWidth = (text: string, font: string): number => {
  const canvas = document.createElement("canvas");
  const context = canvas.getContext("2d");
  if (!context) return 0;
  context.font = font;
  return context.measureText(text).width;
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
      {textItems.map((item, index) => {
        const fontSize = item.height * scale;
        const targetWidth = item.width * scale;
        const fontFamily = "sans-serif";
        const browserWidth = measureTextWidth(item.text, `${fontSize}px ${fontFamily}`);
        const scaleX = browserWidth > 0 ? targetWidth / browserWidth : 1;

        return (
          <span
            key={index}
            style={{
              position: "absolute",
              left: `${item.x * scale}px`,
              top: `${item.y * scale}px`,
              fontSize: `${fontSize}px`,
              fontFamily: fontFamily,
              color: "transparent",
              display: "inline-block",
              pointerEvents: "auto",
              lineHeight: 1,
              whiteSpace: "nowrap",
              transform: `scaleX(${scaleX})`,
              transformOrigin: "left top",
            }}
          >
            {item.text}
          </span>
        );
      })}
    </Box>
  );
}
