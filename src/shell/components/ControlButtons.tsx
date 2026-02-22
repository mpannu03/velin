import { Button, Group } from "@mantine/core";
import { getCurrentWindow } from "@tauri-apps/api/window";
import { useWindowMaximized } from "../hooks";
import { VscChromeClose, VscChromeMaximize, VscChromeMinimize, VscChromeRestore } from "react-icons/vsc";
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
        <VscChromeMinimize />
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
          ? <VscChromeRestore />
          : <VscChromeMaximize />}
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
        <VscChromeClose />
      </Button>
    </Group>
  );
}