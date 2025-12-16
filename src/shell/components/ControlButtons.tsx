import { Button, Group } from "@mantine/core";
import { getCurrentWindow } from "@tauri-apps/api/window";
import { useWindowMaximized } from "../hooks/useWindowMaximized";
import { VscChromeClose, VscChromeMaximize, VscChromeMinimize, VscChromeRestore } from "react-icons/vsc";

export function ControlButtons() {
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
        onClick={() => appWindow.minimize()}
      >
        <VscChromeMinimize />
      </Button>
      <Button
        variant='subtle'
        w="45"
        p="0"
        radius="0"
        onClick={() => appWindow.toggleMaximize()}
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
        style={{
          '--button-hover': 'var(--mantine-color-red-7)',
        }}
        onClick={() => appWindow.close()}
      >
        <VscChromeClose />
      </Button>
    </Group>
  );
}