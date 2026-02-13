import { memo } from "react";
import { Paper } from "@mantine/core";
import { usePdfViewerStore } from "../../stores/pdfViewer.store";
import { Bookmarks } from "./Bookmarks";
import { Comments } from "./Comments";
import { Search } from "./Search";
import { Dictionary } from "./Dictionary";

export const SidePanel = memo(function SidePanel({ id }: { id: string }) {
  const sidebar = usePdfViewerStore(s => s.states[id]?.sidebar ?? 'none');

  if (sidebar === 'none') return null;

  return (
    <Paper
      w={350}
      h="100%"
      p="md"
      withBorder
      style={{
        borderTop: 0,
        borderBottom: 0,
        backgroundColor: 'var(--mantine-color-body)',
      }}
    >
      {sidebar === 'bookmarks' && <Bookmarks id={id} />}
      {sidebar === 'comments' && <Comments id={id} />}
      {sidebar === 'search' && <Search id={id} />}
      {sidebar === 'dictionary' && <Dictionary id={id} />}
    </Paper>
  );
});