import {
  Stack,
  Text,
  Group,
  Paper,
  ActionIcon,
  ScrollArea,
  Center,
} from "@mantine/core";
import { usePdfViewerStore } from "../../stores";
import { Trash, MapPin, Loader } from "lucide-react";
import { formatPdfDateTime } from "@/shared/utils";
import { usePdfAnnotations } from "../../hooks";
import { useEffect, useRef } from "react";
import { Annotation } from "../../types";

export function Comments({ id }: { id: string }) {
  const { annotations, loading, error } = usePdfAnnotations(id);
  const docAnnotations = annotations || [];
  const gotoPage = usePdfViewerStore((s) => s.gotoPage);
  const setAnnotation = usePdfViewerStore((s) => s.setAnnotation);
  const selectedAnnotation = usePdfViewerStore(
    (s) => s.getState(id).selectedAnnotation,
  );

  const selectedRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (selectedAnnotation && selectedRef.current) {
      selectedRef.current.scrollIntoView({
        behavior: "smooth",
        block: "nearest",
        inline: "nearest",
      });
    }
  }, [selectedAnnotation]);

  const annotClicked = (pageIndex: number, annot: Annotation) => {
    if (selectedAnnotation?.id == annot.id) {
      setAnnotation(id, null);
      return;
    }
    gotoPage(id, pageIndex);
    setAnnotation(id, annot);
  };

  if (loading) {
    return (
      <Center h="100%">
        <Loader />
      </Center>
    );
  }

  if (error) {
    return <Text>Error: {error}</Text>;
  }

  return (
    <Stack gap="sm" h="100%">
      <Text fw={700} tt="uppercase" size="xs" c="dimmed">
        Comments ({docAnnotations.length})
      </Text>

      {docAnnotations.length === 0 ? (
        <Text size="sm" c="dimmed" fs="italic" px="xs">
          No annotations yet.
        </Text>
      ) : (
        <ScrollArea style={{ flex: 1 }}>
          <Stack gap="xs" px="xs" pb="xs">
            {docAnnotations.map((annot) => (
              <Paper
                ref={annot.id === selectedAnnotation?.id ? selectedRef : null}
                key={annot.id}
                withBorder
                p="xs"
                shadow="xs"
                bg={
                  annot.id === selectedAnnotation?.id
                    ? "var(--mantine-primary-color-light)"
                    : ""
                }
                style={{
                  cursor: "pointer",
                  borderLeft: `4px solid ${annot.appearance.color}`,
                }}
                onClick={() => annotClicked(annot.page_index, annot)}
              >
                <Group justify="space-between" mb={4}>
                  <Group gap={4}>
                    <MapPin size={14} />
                    <Text size="xs" fw={500}>
                      Page {annot.page_index + 1}
                    </Text>
                    <Text size="xs" c="dimmed">
                      •
                    </Text>
                    <Text size="xs" tt="capitalize" c="dimmed">
                      {annot.subtype}
                    </Text>
                  </Group>
                  <ActionIcon
                    variant="subtle"
                    color="red"
                    size="sm"
                    onClick={(e) => {
                      e.stopPropagation();
                    }}
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
