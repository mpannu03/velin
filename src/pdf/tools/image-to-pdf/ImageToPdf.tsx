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
  Select,
  NumberInput,
  SegmentedControl,
  SimpleGrid,
} from "@mantine/core";
import { JSX } from "react";
import { Save, Pencil } from "lucide-react";
import { useTranslation } from "react-i18next";
import { FileItem, FileSelection } from "../components";
import { pickImageFiles, savePdfFile } from "@/services/file";
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
import { useImageToPdfStore } from "./imageToPdf.store";
import { ImageToPdfPageSize, ImageToPdfOrientation, ImageToPdfFit } from ".";

export function ImageToPdf({
  onBackPressed,
}: ToolPreferencesProps): JSX.Element {
  const { t } = useTranslation("tools");
  const {
    images,
    pageSize,
    orientation,
    fit,
    margin,
    destinationPath,
    isLoading,
    addImages,
    removeImage,
    reorderImages,
    setPageSize,
    setOrientation,
    setFit,
    setMargin,
    setDestinationPath,
    runImageToPdf,
  } = useImageToPdfStore();

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    }),
  );

  const getDefaultDestination = (sourceFile: string = "image") => {
    const filename = sourceFile.split(/[/\\]/).pop() || "";
    const path = sourceFile.substring(0, sourceFile.lastIndexOf(filename));
    const nameWithoutExt = filename.replace(/\.[^/.]+$/, "");
    return `${path}${nameWithoutExt}_compressed.pdf`;
  };

  const pickFiles = async () => {
    const selected = await pickImageFiles(true);
    if (selected && Array.isArray(selected)) {
      addImages(selected);
      if (!destinationPath && images.length === 0) {
        setDestinationPath(getDefaultDestination(selected[0]));
      }
    }
  };

  const handleSaveLocation = async () => {
    const path = await savePdfFile(
      destinationPath || getDefaultDestination(images[0]),
    );
    if (path) {
      setDestinationPath(path);
    }
  };

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (!over || active.id === over.id) return;

    const oldIndex = images.findIndex((f) => f === String(active.id));
    const newIndex = images.findIndex((f) => f === String(over.id));

    reorderImages(arrayMove(images, oldIndex, newIndex));
  };

  const hasImages = images.length > 0;
  const displayDestPath = destinationPath || getDefaultDestination(images[0]);
  const destFilename = displayDestPath.split(/[/\\]/).pop() || displayDestPath;
  const destDir = displayDestPath.substring(
    0,
    displayDestPath.lastIndexOf(destFilename),
  );

  return (
    <ToolDetailShell
      tool={TOOLS.find((t) => t.id === "image-to-pdf")!}
      actionLabel={t("tools.image-to-pdf.action")}
      onAction={runImageToPdf}
      onBackClick={onBackPressed}
      isValid={hasImages && !!displayDestPath && !isLoading}
    >
      <Stack gap="lg" pos="relative">
        <LoadingOverlay visible={isLoading} zIndex={1000} />

        <FileSelection onSelect={pickFiles} multiple hasFiles={hasImages}>
          <DndContext
            sensors={sensors}
            collisionDetection={closestCenter}
            onDragEnd={handleDragEnd}
          >
            <SortableContext
              items={images}
              strategy={verticalListSortingStrategy}
            >
              <Stack gap="xs">
                {images.map((imagePath) => (
                  <SortableFileItem key={imagePath} id={imagePath}>
                    {({ attributes, listeners, isDragging }) => (
                      <FileItem
                        file={imagePath}
                        onRemove={() => removeImage(imagePath)}
                        dragHandleProps={{ ...attributes, ...listeners }}
                        isDragging={isDragging}
                        multiple={true}
                        showSelection={false}
                      />
                    )}
                  </SortableFileItem>
                ))}
              </Stack>
            </SortableContext>
          </DndContext>
        </FileSelection>

        {hasImages && (
          <Stack gap="lg">
            <Paper withBorder p="md" radius="md">
              <Stack gap="md">
                <Text fw={600}>{t("tools.image-to-pdf.options_title")}</Text>

                <SimpleGrid cols={{ base: 1, sm: 2 }} spacing="md">
                  <Stack gap="xs">
                    <Text size="sm" fw={500}>
                      {t("tools.image-to-pdf.page_size.label")}
                    </Text>
                    <SegmentedControl
                      value={pageSize}
                      onChange={(value) =>
                        setPageSize(value as ImageToPdfPageSize)
                      }
                      data={[
                        {
                          label: t("tools.image-to-pdf.page_size.auto"),
                          value: "auto",
                        },
                        {
                          label: t("tools.image-to-pdf.page_size.a4"),
                          value: "a4",
                        },
                        {
                          label: t("tools.image-to-pdf.page_size.letter"),
                          value: "letter",
                        },
                      ]}
                      fullWidth
                      radius="md"
                    />
                  </Stack>

                  <Stack gap="xs">
                    <Text size="sm" fw={500}>
                      {t("tools.image-to-pdf.orientation.label")}
                    </Text>
                    <Select
                      value={orientation}
                      onChange={(v) =>
                        setOrientation((v as ImageToPdfOrientation) || "auto")
                      }
                      data={[
                        {
                          label: t("tools.image-to-pdf.orientation.auto"),
                          value: "auto",
                        },
                        {
                          label: t("tools.image-to-pdf.orientation.portrait"),
                          value: "portrait",
                        },
                        {
                          label: t("tools.image-to-pdf.orientation.landscape"),
                          value: "landscape",
                        },
                      ]}
                      radius="md"
                    />
                  </Stack>

                  <Stack gap="xs">
                    <Text size="sm" fw={500}>
                      {t("tools.image-to-pdf.fit.label")}
                    </Text>
                    <Select
                      value={fit}
                      onChange={(v) =>
                        setFit((v as ImageToPdfFit) || "contain")
                      }
                      data={[
                        {
                          label: t("tools.image-to-pdf.fit.contain"),
                          value: "contain",
                        },
                        {
                          label: t("tools.image-to-pdf.fit.cover"),
                          value: "cover",
                        },
                        {
                          label: t("tools.image-to-pdf.fit.stretch"),
                          value: "stretch",
                        },
                      ]}
                      radius="md"
                    />
                  </Stack>

                  <Stack gap="xs">
                    <Text size="sm" fw={500}>
                      {t("tools.image-to-pdf.margin.label")}
                    </Text>
                    <NumberInput
                      value={margin}
                      onChange={(val) =>
                        setMargin(typeof val === "number" ? val : 20)
                      }
                      min={0}
                      max={100}
                      suffix=" pt"
                      radius="md"
                    />
                  </Stack>
                </SimpleGrid>
              </Stack>
            </Paper>

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
                      <Text
                        size="xs"
                        c="dimmed"
                        tt="uppercase"
                        fw={700}
                        lts={1}
                      >
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
          </Stack>
        )}
      </Stack>
    </ToolDetailShell>
  );
}
