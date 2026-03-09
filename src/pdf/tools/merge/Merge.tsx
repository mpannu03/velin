import {
  Box,
  Group,
  Paper,
  Stack,
  Text,
  ThemeIcon,
  ActionIcon,
  Tooltip,
  Divider,
  LoadingOverlay,
} from "@mantine/core";
import { JSX, useCallback, useEffect, useState } from "react";
import { FiSave, FiEdit2 } from "react-icons/fi";
import { FileItem, FileSelection } from "../components";
import { pickPdfFile, savePdfFile } from "@/services/file";
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
} from "@dnd-kit/core";
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
} from "@dnd-kit/sortable";
import { SortableFileItem } from "../components";
import { ToolPreferencesProps } from "../types";
import { mergePdfs } from "@/services/tauri";
import { notifications } from "@mantine/notifications";

export function Merge({ setAction }: ToolPreferencesProps): JSX.Element {
  const [files, setFiles] = useState<string[]>([]);
  const [destinationPath, setDestinationPath] = useState<string>("");
  const [loading, setLoading] = useState(false);

  const runMerge = useCallback(async () => {
    if (files.length > 0 && !loading) {
      setLoading(true);
      const result = await mergePdfs(files, destinationPath);
      if (result.ok) {
        notifications.show({
          title: "Success",
          message: "PDF files merged successfully.",
          color: "green",
        });
      } else {
        notifications.show({
          title: "Merge Failed",
          message:
            result.error ?? "An unexpected error occurred while merging PDFs.",
          color: "red",
        });
      }
      setLoading(false);
    } else {
      notifications.show({
        title: "No Files Added",
        message: "Please add PDF files to merge.",
        color: "orange",
      });
    }
  }, [files, destinationPath]);

  useEffect(() => {
    setAction(() => runMerge);
  }, [runMerge]);

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    }),
  );

  const getDefaultDestination = (firstFile: string) => {
    const filename = firstFile.split(/[/\\]/).pop() || "";
    const path = firstFile.substring(0, firstFile.lastIndexOf(filename));
    const nameWithoutExt = filename.replace(/\.[^/.]+$/, "");
    return `${path}${nameWithoutExt}_merged.pdf`;
  };

  const pickFiles = async () => {
    const file = await pickPdfFile();
    if (file) {
      setFiles((prev) => {
        const newFiles = [...prev, file];
        if (prev.length === 0) {
          setDestinationPath(getDefaultDestination(file));
        }
        return newFiles;
      });
    }
  };

  const handleSaveLocation = async () => {
    const path = await savePdfFile(destinationPath);
    if (path) {
      setDestinationPath(path);
    }
  };

  const removeFile = (file: string) => {
    setFiles((prev) => prev.filter((f) => f !== file));
  };

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (over && active.id !== over.id) {
      setFiles((items) => {
        const oldIndex = items.indexOf(active.id as string);
        const newIndex = items.indexOf(over.id as string);
        return arrayMove(items, oldIndex, newIndex);
      });
    }
  };

  const hasFiles = files.length > 0;
  const destFilename = destinationPath.split(/[/\\]/).pop() || destinationPath;
  const destDir = destinationPath.substring(
    0,
    destinationPath.lastIndexOf(destFilename),
  );

  return (
    <Stack gap="lg" pos="relative">
      <LoadingOverlay visible={loading} zIndex={1000} />
      <FileSelection onSelect={pickFiles} multiple hasFiles={hasFiles}>
        <DndContext
          sensors={sensors}
          collisionDetection={closestCenter}
          onDragEnd={handleDragEnd}
        >
          <SortableContext items={files} strategy={verticalListSortingStrategy}>
            <Stack gap="xs">
              {files.map((file) => (
                <SortableFileItem key={file} id={file}>
                  {({ attributes, listeners, isDragging }) => (
                    <FileItem
                      file={file}
                      onRemove={() => removeFile(file)}
                      dragHandleProps={{ ...attributes, ...listeners }}
                      isDragging={isDragging}
                    />
                  )}
                </SortableFileItem>
              ))}
            </Stack>
          </SortableContext>
        </DndContext>
      </FileSelection>

      {hasFiles && (
        <Stack gap="md">
          <Divider label="Output Destination" labelPosition="center" />

          <Paper
            withBorder
            p="md"
            radius="md"
            bg="light-dark(var(--mantine-color-gray-0), var(--mantine-color-dark-8))"
            style={{ borderStyle: "solid" }}
          >
            <Group justify="space-between" wrap="nowrap">
              <Group gap="md" wrap="nowrap" style={{ flex: 1 }}>
                <ThemeIcon variant="light" size="lg" radius="md">
                  <FiSave size={20} />
                </ThemeIcon>
                <Box style={{ flex: 1, minWidth: 0 }}>
                  <Text size="xs" c="dimmed" tt="uppercase" fw={700} lts={1}>
                    Destination File
                  </Text>
                  <Text size="sm" fw={600} truncate="end">
                    {destFilename}
                  </Text>
                  <Text size="xs" c="dimmed" truncate="end" title={destDir}>
                    {destDir}
                  </Text>
                </Box>
              </Group>
              <Tooltip label="Change destination" withArrow>
                <ActionIcon
                  variant="light"
                  color="blue"
                  size="lg"
                  radius="md"
                  onClick={handleSaveLocation}
                >
                  <FiEdit2 size={18} />
                </ActionIcon>
              </Tooltip>
            </Group>
          </Paper>
        </Stack>
      )}
    </Stack>
  );
}
