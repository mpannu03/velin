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
      {textItems.map((item, index) => (
        <span
          key={index}
          style={{
            position: "absolute",
            left: `${item.x * scale}px`,
            top: `${item.y * scale}px`,
            fontSize: `${item.height * scale}px`,
            fontFamily: "sans-serif",
            color: "transparent",
            whiteSpace: "pre",
            transformOrigin: "left top",
            // We use a small trick to make sure the selection block matches the visual text
            // even if the font doesn't perfectly match the PDF font.
            display: "inline-block",
            pointerEvents: "auto",
          }}
        >
          {item.text}
        </span>
      ))}
    </Box>
  );
}
