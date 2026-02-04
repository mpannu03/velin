import { Paper, Stack, Text } from "@mantine/core";
import { usePdfViewerStore } from "../stores/pdf_viewer.store";

export function SidePanel({ id }: { id: string }) {
  const viewerState = usePdfViewerStore(s => s.getState(id));
  return (
    <>
      {viewerState.sidebar !== 'none' && (
        <Paper
          w={250}
          h="100%"
          p="md"
          withBorder
          style={{
            borderTop: 0,
            borderBottom: 0,
            backgroundColor: 'var(--mantine-color-body)',
          }}
        >
          <Stack gap="sm">
            <Text fw={700} tt="uppercase" size="xs" c="dimmed">
              {viewerState.sidebar}
            </Text>
            <Text size="sm" c="dimmed" fs="italic">
              No {viewerState.sidebar} yet.
            </Text>
          </Stack>
        </Paper>
      )}
    </>
  );
}