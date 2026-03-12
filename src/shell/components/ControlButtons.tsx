import { Button, Group } from "@mantine/core";
import { getCurrentWindow } from "@tauri-apps/api/window";
import { useWindowMaximized } from "../hooks";
import { Minus, Square, Copy, X } from "lucide-react";
import { JSX } from "react";

export function ControlButtons(): JSX.Element {
  const appWindow = getCurrentWindow();
  const isMaximized = useWindowMaximized();

  return(
    <Group
      justify="flex-end"
      gap="0"
      >
      <Button
        variant='subtle'
        w="45"
        p="0"
        radius="0"
        color="var(--mantine-color-text)"
        onClick={() => appWindow.minimize()}
        aria-label="Minimize"
      >
        <Minus size={16} />
      </Button>
      <Button
        variant='subtle'
        w="45"
        p="0"
        radius="0"
        color="var(--mantine-color-text)"
        onClick={() => appWindow.toggleMaximize()}
        aria-label={isMaximized ? "Restore" : "Maximize"}
      >
        {isMaximized
          ? <Copy size={14} />
          : <Square size={14} />}
      </Button>
      <Button
        variant='subtle'
        w="45"
        p="0"
        radius="0"
        color="var(--mantine-color-text)"
        style={{
          '--button-hover': 'var(--mantine-color-red-7)',
        }}
        onClick={() => appWindow.close()}
        aria-label="Close"
      >
        <X size={16} />
      </Button>
    </Group>
  );
}