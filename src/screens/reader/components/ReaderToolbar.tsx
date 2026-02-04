import { ActionIcon, Paper, Stack, Text, Tooltip } from '@mantine/core';
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
