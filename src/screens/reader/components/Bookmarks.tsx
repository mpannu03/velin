import { Box, Button, Collapse, Group, Loader, ScrollArea, Stack, Text } from "@mantine/core";
import { usePdfBookmarks } from "../hooks";
import { Bookmark } from "@/shared/types";
import { useState } from "react";
import { ChevronDown, ChevronRight } from "lucide-react";
import { usePdfViewerStore } from "../stores";

export function Bookmarks({ id }: { id: string }) {
  const { bookmarks, error, loading } = usePdfBookmarks(id);
  const items = bookmarks?.items ?? [];

  if (loading) {
    return <Loader />;
  }

  if (error) {
    return <Text>Error: {error}</Text>;
  }

  console.log(items);

  return (
    <Stack gap="sm" h="100%">
      <Text fw={700} tt="uppercase" size="xs" c="dimmed">
        Bookmarks
      </Text>
      {items.length === 0 ? (
        <Text size="sm" c="dimmed" fs="italic">
          No bookmarks yet.
        </Text>
      ) : (
        <ScrollArea h="100%" scrollbars="y">
          <Stack gap={4}>
            {items.map((bm, i) => (
              <BookmarkItem key={`${bm.title}-${i}`} id={id} bookmark={bm} />
            ))}
          </Stack>
        </ScrollArea>
      )}
    </Stack>
  );
}

type BookmarkProps = {
  id: string;
  bookmark: Bookmark;
  level?: number;
};

function BookmarkItem({ id, bookmark, level = 0 }: BookmarkProps) {
  const [opened, setOpened] = useState(false);
  const hasChildren = bookmark.children.length > 0;

  const gotoPage = usePdfViewerStore((s) => s.gotoPage);

  return (
    <Box>
      <Group
        gap="xs"
        wrap="nowrap"
        style={{ cursor: hasChildren ? "pointer" : "default" }}
      >
        {hasChildren ? (
          opened ? <ChevronDown size={14} style={{ flexShrink: 0 }} onClick={() => setOpened((o) => !o)} />
            : <ChevronRight size={14} style={{ flexShrink: 0 }} onClick={() => setOpened((o) => !o)} />
        ) : (
          <Box w={14} style={{ flexShrink: 0 }} />
        )}

        <Button variant="subtle"
          onClick={() => {
            if (bookmark.page_index !== null) {
              gotoPage(id, bookmark.page_index);
            }
          }}>
          <Text size="sm" c="black" style={{ wordBreak: "break-word" }}>
            {bookmark.title}
          </Text>
        </Button>
      </Group>

      {hasChildren && (
        <Collapse in={opened}>
          {bookmark.children.map((child, idx) => (
            <BookmarkItem
              key={`${bookmark.title}-${idx}`}
              id={id}
              bookmark={child}
              level={level + 1}
            />
          ))}
        </Collapse>
      )}
    </Box>
  );
}
