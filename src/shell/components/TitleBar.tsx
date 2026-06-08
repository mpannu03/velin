import { Group } from '@mantine/core';
import { ControlButtons } from './';
import { JSX } from 'react';
import { PdfTabs } from './PdfTabs';

export function TitleBar(): JSX.Element {
  return(
    <Group
      data-testid="title-bar"
      data-tauri-drag-region
      w="100%"
      h="36px"
      justify="space-between"
      align="center"
      bg="var(--mantine-color-disabled)"
      style={{
        borderBottom: '1px solid var(--mantine-color-disabled-border)',
      }}
    >
      <PdfTabs />
      <ControlButtons />
    </Group>
  );
}