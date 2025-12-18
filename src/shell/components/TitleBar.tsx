import { Group } from '@mantine/core';
import { ControlButtons } from './ControlButtons';
import { JSX } from 'react';
import { PdfTabs } from './PdfTabs';

export function TitleBar(): JSX.Element {
  return(
    <Group
    data-tauri-drag-region
    w="100%"
    h="36px"
    justify="space-between"
    align="center"
    bg="gray.2"
    style={{
      borderBottom: '1px solid var(--mantine-color-gray-3)',
    }}
    >
      <PdfTabs />
      <ControlButtons />
    </Group>
  );
}