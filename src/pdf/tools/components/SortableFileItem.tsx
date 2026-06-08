import { useSortable } from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";
import { ReactNode } from "react";
import { Box } from "@mantine/core";

interface SortableFileItemProps {
  id: string;
  children: (props: any) => ReactNode;
}

export function SortableFileItem({ id, children }: SortableFileItemProps) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    zIndex: isDragging ? 1 : 0,
    opacity: isDragging ? 0.5 : 1,
    position: "relative" as const,
  };

  return (
    <Box ref={setNodeRef} style={style}>
      {children({ attributes, listeners, isDragging })}
    </Box>
  );
}
