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
} from "@mantine/core";
import { JSX, useState } from "react";
import { FiFileText, FiMove, FiTrash2, FiSave, FiEdit2 } from "react-icons/fi";
import { FileSelection } from "./FileSelection";
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
import { SortableFileItem } from "../SortableFileItem";

export function MergePreferences(): JSX.Element {
  const [files, setFiles] = useState<string[]>([]);
  const [destinationPath, setDestinationPath] = useState<string>("");

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
        if (prev.length === 0 && !destinationPath) {
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
    <Stack gap="lg">
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
                <ThemeIcon variant="light" color="green" size="lg" radius="md">
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

interface FileItemProps {
  file: string;
  onRemove: () => void;
  dragHandleProps?: any;
  isDragging?: boolean;
}

function FileItem({
  file,
  onRemove,
  dragHandleProps,
  isDragging,
}: FileItemProps) {
  // Extract filename from path
  const filename = file.split(/[/\\]/).pop() || file;
  const path = file.substring(0, file.lastIndexOf(filename));

  return (
    <Paper
      withBorder
      p="sm"
      radius="md"
      shadow={isDragging ? "md" : "xs"}
      style={{
        backgroundColor: isDragging
          ? "light-dark(var(--mantine-color-blue-0), var(--mantine-color-dark-6))"
          : "light-dark(var(--mantine-color-white), var(--mantine-color-dark-7))",
        borderColor: isDragging
          ? "var(--mantine-color-blue-filled)"
          : undefined,
        cursor: "default",
        transition: "all 0.2s ease",
      }}
    >
      <Group justify="space-between" wrap="nowrap">
        <Group gap="md" wrap="nowrap" style={{ flex: 1 }}>
          <Tooltip label="Drag to reorder" position="left" withArrow>
            <ActionIcon
              variant="subtle"
              color="gray"
              size="md"
              style={{ cursor: "grab" }}
              {...dragHandleProps}
            >
              <FiMove size={18} />
            </ActionIcon>
          </Tooltip>

          <ThemeIcon variant="light" color="blue" size="lg" radius="md">
            <FiFileText size={20} />
          </ThemeIcon>

          <Box style={{ flex: 1, minWidth: 0 }}>
            <Text size="sm" fw={600} truncate="end">
              {filename}
            </Text>
            <Text size="xs" c="dimmed" truncate="end" title={path}>
              {path}
            </Text>
          </Box>
        </Group>

        <Tooltip label="Remove file" withArrow>
          <ActionIcon variant="subtle" color="red" onClick={onRemove} size="md">
            <FiTrash2 size={18} />
          </ActionIcon>
        </Tooltip>
      </Group>
    </Paper>
  );
}
