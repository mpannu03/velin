import { JSX, Fragment } from "react";
import { Annotation } from "../types";

type AnnotationLayerProps = {
  annotations: Annotation[];
  scale: number;
  width: number;
  height: number;
  onAnnotationClick?: (annotation: Annotation) => void;
};

export function AnnotationLayer({
  annotations,
  scale,
  width,
  height,
  onAnnotationClick,
}: AnnotationLayerProps): JSX.Element {
  return (
    <div
      className="annotation-layer"
      style={{
        position: "absolute",
        top: 0,
        left: 0,
        width: width,
        height: height,
        pointerEvents: "none",
        zIndex: 10,
      }}
    >
      {annotations.map((annotation) => {
        const { geometry, appearance, metadata, id } = annotation;
        
        if (geometry.type === "quadpoints") {
            return (
                <Fragment key={id}>
                {geometry.data.map((quad, idx) => {
                    // Quad points are counter-clockwise: p1(bottom-left), p2(bottom-right), p3(top-right), p4(top-left)
                    // We can use the bounding box of each quad for highlighting.
                    const left = Math.min(quad.p1.x, quad.p4.x);
                    const top = Math.min(quad.p3.y, quad.p4.y);
                    const right = Math.max(quad.p2.x, quad.p3.x);
                    const bottom = Math.max(quad.p1.y, quad.p2.y);

                    const style: React.CSSProperties = {
                        position: "absolute",
                        left: `${left * scale}px`,
                        top: `${top * scale}px`,
                        width: `${(right - left) * scale}px`,
                        height: `${(bottom - top) * scale}px`,
                        backgroundColor: appearance.color,
                        opacity: appearance.opacity,
                        cursor: "pointer",
                        pointerEvents: "auto",
                    };

                    return (
                        <div
                            key={`${id}-${idx}`}
                            style={style}
                            onClick={(e) => {
                                e.stopPropagation();
                                onAnnotationClick?.(annotation);
                            }}
                            title={metadata.contents || annotation.subtype}
                        />
                    );
                })}
                </Fragment>
            );
        }

        // Fallback to bounding rect if not quadpoints (e.g. for simple shapes)
        const { rect } = annotation;
        const style: React.CSSProperties = {
            position: "absolute",
            left: `${rect.left * scale}px`,
            top: `${rect.top * scale}px`,
            width: `${(rect.right - rect.left) * scale}px`,
            height: `${(rect.bottom - rect.top) * scale}px`,
            backgroundColor: appearance.color,
            opacity: appearance.opacity,
            cursor: "pointer",
            pointerEvents: "auto",
            border: appearance.border_width ? `${appearance.border_width * scale}px solid ${appearance.color}` : undefined,
        };

        return (
          <div
            key={id}
            style={style}
            onClick={(e) => {
                e.stopPropagation();
                onAnnotationClick?.(annotation);
            }}
            title={metadata.contents || annotation.subtype}
          />
        );
      })}
    </div>
  );
}
