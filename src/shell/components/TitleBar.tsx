import { Group } from '@mantine/core';
import { ControlButtons } from './ControlButtons';

export function TitleBar() {
  return(
    <Group
    data-tauri-drag-region
    w="100%"
    h="36px"
    justify="space-between"
    align="center"
    bg="gray.1"
    style={{
      borderBottom: '1px solid var(--mantine-color-gray-3)',
    }}
    >
      <Group></Group>
      <ControlButtons />
    </Group>
  );
}