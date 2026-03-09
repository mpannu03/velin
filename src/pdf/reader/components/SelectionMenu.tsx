import { JSX, useEffect } from "react";
import { Group, ActionIcon, Paper, Tooltip } from "@mantine/core";
import { Highlighter, BookOpen, Copy } from "lucide-react";

type SelectionMenuProps = {
  x: number;
  y: number;
  onHighlight: () => void;
  onDictionary: () => void;
  onCopy: () => void;
  onClose: () => void;
};

export function SelectionMenu({
  x,
  y,
  onHighlight,
  onDictionary,
  onCopy,
  onClose,
}: SelectionMenuProps): JSX.Element {
    
    // detect click outside to close
    useEffect(() => {
      const handleClick = (e: MouseEvent) => {
        if (e.target instanceof Node) {
            onClose();
        }
      };
      window.addEventListener('mousedown', handleClick);
      return () => window.removeEventListener('mousedown', handleClick);
    }, [onClose]);

  return (
    <Paper
      shadow="md"
      radius="md"
      p={4}
      style={{
        position: "fixed",
        top: y - 50, // position above selection
        left: x,
        zIndex: 1000,
        pointerEvents: "auto",
      }}
    >
      <Group gap={4}>
        <Tooltip label="Highlight">
          <ActionIcon variant="light" color="yellow" onClick={onHighlight}>
            <Highlighter size={18} />
          </ActionIcon>
        </Tooltip>
        <Tooltip label="Dictionary">
          <ActionIcon variant="light" color="blue" onClick={onDictionary}>
            <BookOpen size={18} />
          </ActionIcon>
        </Tooltip>
        <Tooltip label="Copy">
          <ActionIcon variant="light" color="gray" onClick={onCopy}>
            <Copy size={18} />
          </ActionIcon>
        </Tooltip>
      </Group>
    </Paper>
  );
}
