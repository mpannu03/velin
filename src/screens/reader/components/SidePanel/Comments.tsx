import { Stack, Text, Group, Paper, ActionIcon, ScrollArea } from "@mantine/core";
import { useAnnotationsStore, usePdfViewerStore } from "../../stores";
import { useEffect } from "react";
import { Trash, MapPin } from "lucide-react";
import { formatPdfDateTime, parsePdfDate } from "@/shared/utils";

export function Comments({ id }: { id: string }) {
  const { annotations, fetchAnnotations, removeAnnotation } = useAnnotationsStore();
  const docAnnotations = annotations[id] || [];
  const gotoPage = usePdfViewerStore(s => s.gotoPage);

  console.log(docAnnotations);

  useEffect(() => {
    fetchAnnotations(id);
  }, [id, fetchAnnotations]);

  const handleDelete = (e: React.MouseEvent, pageIndex: number, annotId: string) => {
      e.stopPropagation();
      removeAnnotation(id, pageIndex, annotId);
  }

  const handleJump = (pageIndex: number) => {
      gotoPage(id, pageIndex);
  }

  return (
    <Stack gap="sm" h="100%">
      <Text fw={700} tt="uppercase" size="xs" c="dimmed">
        Comments ({docAnnotations.length})
      </Text>
      
      {docAnnotations.length === 0 ? (
        <Text size="sm" c="dimmed" fs="italic" px="xs">
          No annotations yet. Select text to highlight.
        </Text>
      ) : (
        <ScrollArea style={{ flex: 1 }}>
            <Stack gap="xs" px="xs" pb="xs">
                {docAnnotations.map((annot) => (
                    <Paper key={annot.id} withBorder p="xs" shadow="xs" 
                        style={{ 
                            cursor: 'pointer',
                            borderLeft: `4px solid ${annot.appearance.color}` 
                        }}
                        onClick={() => handleJump(annot.page_index)}
                    >
                        <Group justify="space-between" mb={4}>
                            <Group gap={4}>
                                <MapPin size={14} />
                                <Text size="xs" fw={500}>Page {annot.page_index + 1}</Text>
                                <Text size="xs" c="dimmed">•</Text>
                                <Text size="xs" tt="capitalize" c="dimmed">{annot.subtype}</Text>
                            </Group>
                            <ActionIcon variant="subtle" color="red" size="sm" 
                                onClick={(e) => handleDelete(e, annot.page_index, annot.id)}
                            >
                                <Trash size={14} />
                            </ActionIcon>
                        </Group>
                        <Text size="sm" lineClamp={3} fw={500}>
                            {annot.metadata.contents || "No content"}
                        </Text>
                        <Group justify="space-between" mt={4}>
                            <Text size="xs" c="dimmed">
                                {annot.metadata.author || "Anonymous"}
                            </Text>
                            <Text size="xs" c="dimmed">
                                {annot.metadata.creation_date
                                    ? formatPdfDateTime(annot.metadata.creation_date)
                                    : ""}
                            </Text>
                        </Group>
                    </Paper>
                ))}
            </Stack>
        </ScrollArea>
      )}
    </Stack>
  );
}