import { ActionIcon, Divider, Input, Paper, Stack, Text, Tooltip } from '@mantine/core';
import { useHotkeys } from '@mantine/hooks';
import { usePdfViewerStore } from '../stores/pdf_viewer.store';
import {
  ZoomIn,
  ZoomOut,
  Hand,
  MousePointer,
  MessageCircle,
  Bookmark
} from "lucide-react";
import { usePageIndicator } from '../hooks';
import { useEffect, useState } from 'react';

type ReaderToolbarProps = {
    documentId: string;
};

export function ReaderToolbar({ documentId }: ReaderToolbarProps) {
  const state = usePdfViewerStore(s => s.getState(documentId));
  const zoomIn = () => usePdfViewerStore.getState().zoomIn(documentId);
  const zoomOut = () => usePdfViewerStore.getState().zoomOut(documentId);
  const resetZoom = () => usePdfViewerStore.getState().resetZoom(documentId);
  const setTool = usePdfViewerStore.getState().setTool;
  const setSidebar = usePdfViewerStore.getState().setSidebar;
  const pageIndicator = usePageIndicator(documentId);

  useHotkeys([
    ['mod+plus', zoomIn],
    ['mod+minus', zoomOut],
    ['mod+0', resetZoom],
  ]);

  return (
    <Paper
      shadow="xs"
      p="xs"
      withBorder
      style={{
        width: 50,
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'space-between',
          backgroundColor: 'var(--mantine-color-body)',
          borderLeft: '1px solid var(--mantine-color-gray-3)',
      }}
    >
      <Stack gap="xs" align="center">
        <Tooltip label="Selection Tool" position="left">
          <ActionIcon
            variant={state.tool === 'cursor' ? 'filled' : 'light'}
            onClick={() => setTool(documentId, 'cursor')}
            size="lg"
          >
            <MousePointer size={20} />
          </ActionIcon>
        </Tooltip>
        <Tooltip label="Hand Tool" position="left">
          <ActionIcon
            variant={state.tool === 'hand' ? 'filled' : 'light'}
            onClick={() => setTool(documentId, 'hand')}
            size="lg"
          >
            <Hand size={20} />
          </ActionIcon>
        </Tooltip>
      </Stack>

      <Stack align="center" gap="xs">
        <Tooltip label="Zoom In (Ctrl+Plus)" position="left">
          <ActionIcon variant="light" onClick={zoomIn} size="lg">
            <ZoomIn size={20} />
          </ActionIcon>
        </Tooltip>

        <Tooltip label="Reset Zoom (Ctrl+0)" position="left">
          <Text 
            size="xs" 
            fw={700} 
            style={{ fontSize: 11, textAlign: 'center', cursor: 'pointer' }}
            onClick={resetZoom}
          >
            {Math.round(state.scale * 100)}%
          </Text>
        </Tooltip>

        <Tooltip label="Zoom Out (Ctrl+Minus)" position="left">
          <ActionIcon variant="light" onClick={zoomOut} size="lg">
            <ZoomOut size={20} />
          </ActionIcon>
        </Tooltip>

        <PageGotoInput id={documentId} />
        <Divider w={16} />
        <Text size="xs" c="dimmed">
          {pageIndicator?.total}
        </Text>

      </Stack>

      <Stack gap="xs" align="center">
        <Tooltip label="Comments" position="left">
          <ActionIcon
            variant={state.sidebar === 'comments' ? 'filled' : 'light'}
            size="lg"
            onClick={() => setSidebar(documentId, state.sidebar === 'comments' ? 'none' : 'comments')}
          >
            <MessageCircle size={20} />
          </ActionIcon>
        </Tooltip>
        <Tooltip label="Bookmarks" position="left">
          <ActionIcon
            variant={state.sidebar === 'bookmarks' ? 'filled' : 'light'}
            size="lg"
            onClick={() => setSidebar(documentId, state.sidebar === 'bookmarks' ? 'none' : 'bookmarks')}
          >
            <Bookmark size={20} />
          </ActionIcon>
        </Tooltip>
      </Stack>
    </Paper>
    );
}

function PageGotoInput({ id }: { id: string }) {
  const pageIndicator = usePageIndicator(id);
  const goToPage = usePdfViewerStore((s) => s.gotoPage);

  const [value, setValue] = useState(
    pageIndicator?.current.toString() ?? ""
  );

  useEffect(() => {
    setValue(pageIndicator?.current.toString() ?? "");
  }, [pageIndicator?.current]);

  if (!pageIndicator) return null;

  const submit = (element: HTMLInputElement) => {
    const num = Number(value);
    if (!Number.isInteger(num)) return;

    const pageIndex = Math.min(
      Math.max(num - 1, 0),
      pageIndicator.total - 1
    );

    goToPage(id, pageIndex);
    element?.blur();
  };

  return (
    <Input
      size="xs"
      value={value}
      onChange={(e) => setValue(e.currentTarget.value)}
      onBlur={(e) => submit(e.currentTarget)}
      onKeyDown={(e) => {
        if (e.key === "Enter") submit(e.currentTarget);
        if (e.key === "Escape") {
          setValue(pageIndicator.current.toString());
          e.currentTarget.blur();
        }
      }}
      styles={{
        input: {
          textAlign: "center",
          padding: 4,
        },
      }}
    />
  );
}

