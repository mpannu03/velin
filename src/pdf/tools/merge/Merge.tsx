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
import { JSX } from "react";
import { Save, Pencil } from "lucide-react";
import { useTranslation } from "react-i18next";
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
import { ToolPreferencesProps, TOOLS } from "../types";
import { ToolDetailShell } from "../components";
import { useMergeState } from "./merge.store";

export function Merge({ onBackPressed }: ToolPreferencesProps): JSX.Element {
  const { t } = useTranslation("tools");
  const {
    inputs,
    destinationPath,
    isLoading,
    addFiles,
    setFiles,
    removeFile,
    setDestinationPath,
    runMerge,
    updateFileSelection,
  } = useMergeState();

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
    const selected = await pickPdfFile(true);
    if (selected) {
      const newFiles = Array.isArray(selected) ? selected : [selected];
      addFiles(newFiles);
      if (inputs.length === 0 && newFiles.length > 0) {
        setDestinationPath(getDefaultDestination(newFiles[0]));
      }
    }
  };

  const handleSaveLocation = async () => {
    const path = await savePdfFile(destinationPath);
    if (path) {
      setDestinationPath(path);
    }
  };

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (!over || active.id === over.id) return;

    const oldIndex = inputs.findIndex((f) => f.file === String(active.id));
    const newIndex = inputs.findIndex((f) => f.file === String(over.id));

    setFiles(arrayMove(inputs, oldIndex, newIndex));
  };

  const hasFiles = inputs.length > 0;
  const destFilename = destinationPath.split(/[/\\]/).pop() || destinationPath;
  const destDir = destinationPath.substring(
    0,
    destinationPath.lastIndexOf(destFilename),
  );

  return (
    <ToolDetailShell
      tool={TOOLS.find((t) => t.id === "merge")!}
      actionLabel={t("tools.merge.action")}
      onAction={runMerge}
      onBackClick={onBackPressed}
      isValid={hasFiles && !isLoading}
    >
      <Stack gap="lg" pos="relative">
        <LoadingOverlay visible={isLoading} zIndex={1000} />
        <FileSelection onSelect={pickFiles} multiple hasFiles={hasFiles}>
          <DndContext
            sensors={sensors}
            collisionDetection={closestCenter}
            onDragEnd={handleDragEnd}
          >
            <SortableContext
              items={inputs.map((f) => f.file)}
              strategy={verticalListSortingStrategy}
            >
              <Stack gap="xs">
                {inputs.map((fileInput) => (
                  <SortableFileItem key={fileInput.file} id={fileInput.file}>
                    {({ attributes, listeners, isDragging }) => (
                      <FileItem
                        file={fileInput.file}
                        selection={fileInput.selection}
                        onSelectionChange={(val) =>
                          updateFileSelection(fileInput.file, val)
                        }
                        onRemove={() => removeFile(fileInput.file)}
                        dragHandleProps={{ ...attributes, ...listeners }}
                        isDragging={isDragging}
                        showSelection={true}
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
            <Divider
              label={t("components.destination.output_destination")}
              labelPosition="center"
            />

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
                    <Save size={20} />
                  </ThemeIcon>
                  <Box style={{ flex: 1, minWidth: 0 }}>
                    <Text size="xs" c="dimmed" tt="uppercase" fw={700} lts={1}>
                      {t("components.destination.destination_file")}
                    </Text>
                    <Text size="sm" fw={600} truncate="end">
                      {destFilename}
                    </Text>
                    <Text size="xs" c="dimmed" truncate="end" title={destDir}>
                      {destDir}
                    </Text>
                  </Box>
                </Group>
                <Tooltip
                  label={t("components.destination.tooltip_file")}
                  withArrow
                >
                  <ActionIcon
                    variant="light"
                    color="blue"
                    size="lg"
                    radius="md"
                    onClick={handleSaveLocation}
                  >
                    <Pencil size={18} />
                  </ActionIcon>
                </Tooltip>
              </Group>
            </Paper>
          </Stack>
        )}
      </Stack>
    </ToolDetailShell>
  );
}
