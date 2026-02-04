import { Paper } from "@mantine/core";
import { usePdfViewerStore } from "../stores/pdf_viewer.store";
import { Bookmarks } from "./Bookmarks";
import { Comments } from "./Comments";

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
          {viewerState.sidebar === 'bookmarks' && <Bookmarks id={id} />}
          {viewerState.sidebar === 'comments' && <Comments id={id} />}
        </Paper>
      )}
    </>
  );
}