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
  TextInput,
  Select,
  Slider,
  SegmentedControl,
  SimpleGrid,
} from "@mantine/core";
import { JSX } from "react";
import { Folder, Pencil } from "lucide-react";
import { useTranslation } from "react-i18next";
import { FileItem, FileSelection } from "../components";
import { pickDirectory, pickPdfFile } from "@/services/file";
import { ToolPreferencesProps, TOOLS } from "../types";
import { ToolDetailShell } from "../components";
import { usePdfToImageStore } from "./pdfToImage.store";
import { ImageMode, ImageType } from ".";

export function PdfToImage({
  onBackPressed,
}: ToolPreferencesProps): JSX.Element {
  const { t } = useTranslation("tools");
  const {
    file,
    selection,
    format,
    dpi,
    quality,
    mode,
    pattern,
    destinationDir,
    isLoading,
    setFile,
    setSelection,
    setFormat,
    setDpi,
    setQuality,
    setMode,
    setPattern,
    setDestinationDir,
    removeFile,
    runPdfToImage,
  } = usePdfToImageStore();

  const getDefaultDestinationDir = (filePath: string) => {
    const filename = filePath.split(/[/\\]/).pop() || "";
    return filePath.substring(0, filePath.lastIndexOf(filename));
  };

  const pickFile = async () => {
    const selected = await pickPdfFile(false);
    if (selected && typeof selected === "string") {
      setFile(selected);
      if (!destinationDir) {
        setDestinationDir(getDefaultDestinationDir(selected));
      }
    }
  };

  const handlePickDirectory = async () => {
    const dir = await pickDirectory();
    if (dir) {
      setDestinationDir(dir);
    }
  };

  const hasFile = file !== "";
  const displayDestDir =
    destinationDir || (hasFile ? getDefaultDestinationDir(file) : "");
  // Get just the directory name for the bold title
  const destDirName =
    displayDestDir.split(/[/\\]/).filter(Boolean).pop() || displayDestDir;
  // Get the parent path for the dimmed text
  const parentPath = displayDestDir.substring(
    0,
    displayDestDir.lastIndexOf(destDirName),
  );

  return (
    <ToolDetailShell
      tool={TOOLS.find((t) => t.id === "pdf-to-image")!}
      actionLabel={t("tools.pdf-to-image.action")}
      onAction={runPdfToImage}
      onBackClick={onBackPressed}
      isValid={hasFile && !isLoading}
    >
      <Stack gap="lg" pos="relative">
        <LoadingOverlay visible={isLoading} zIndex={1000} />

        <FileSelection onSelect={pickFile} hasFiles={hasFile}>
          <FileItem file={file} onRemove={removeFile} multiple={false} />
        </FileSelection>

        {hasFile && (
          <Stack gap="lg">
            <Paper withBorder p="md" radius="md">
              <Stack gap="md">
                <Text fw={600}>{t("tools.pdf-to-image.options_title")}</Text>

                <SimpleGrid cols={{ base: 1, sm: 2 }} spacing="md">
                  <Stack gap="xs">
                    <Text size="sm" fw={500}>
                      {t("tools.pdf-to-image.format.label")}
                    </Text>
                    <SegmentedControl
                      value={format}
                      onChange={(value) => setFormat(value as ImageType)}
                      data={[
                        { label: "PNG", value: "png" },
                        { label: "JPEG", value: "jpeg" },
                        { label: "WebP", value: "webp" },
                      ]}
                      fullWidth
                      radius="md"
                    />
                  </Stack>

                  <Stack gap="xs">
                    <Text size="sm" fw={500}>
                      {t("tools.pdf-to-image.dpi.label")}
                    </Text>
                    <Select
                      value={dpi.toString()}
                      onChange={(v) => setDpi(parseInt(v || "300"))}
                      data={[
                        { label: "72 DPI (Low)", value: "72" },
                        { label: "150 DPI (Medium)", value: "150" },
                        { label: "300 DPI (High)", value: "300" },
                        { label: "600 DPI (Ultra)", value: "600" },
                      ]}
                      radius="md"
                    />
                  </Stack>

                  <Stack gap="xs">
                    <Text size="sm" fw={500}>
                      {t("tools.pdf-to-image.mode.label")}
                    </Text>
                    <Select
                      value={mode}
                      onChange={(v) => setMode((v as ImageMode) || "color")}
                      data={[
                        {
                          label: t("tools.pdf-to-image.mode.color"),
                          value: "color",
                        },
                        {
                          label: t("tools.pdf-to-image.mode.grayscale"),
                          value: "grayscale",
                        },
                      ]}
                      radius="md"
                    />
                  </Stack>

                  <Stack gap="xs">
                    <Text size="sm" fw={500}>
                      {t("tools.pdf-to-image.quality.label")}
                    </Text>
                    <Box pt="xs" px="xs" pb="lg">
                      <Slider
                        value={quality}
                        onChange={setQuality}
                        min={1}
                        max={100}
                        label={(value) => `${value}%`}
                        marks={[
                          { value: 25, label: "25%" },
                          { value: 50, label: "50%" },
                          { value: 75, label: "75%" },
                        ]}
                      />
                    </Box>
                    <Text size="xs" c="dimmed">
                      {t("tools.pdf-to-image.quality.description")}
                    </Text>
                  </Stack>
                </SimpleGrid>

                <Divider />

                <Stack gap="xs">
                  <Text size="sm" fw={500}>
                    {t("components.file_item.selection_placeholder")}
                  </Text>
                  <TextInput
                    value={selection}
                    onChange={(e) => setSelection(e.currentTarget.value)}
                    placeholder="e.g. 1-5, 8, 11-13"
                    radius="md"
                  />
                </Stack>

                <Stack gap="xs">
                  <Text size="sm" fw={500}>
                    {t("tools.pdf-to-image.pattern.label")}
                  </Text>
                  <TextInput
                    value={pattern}
                    onChange={(e) => setPattern(e.currentTarget.value)}
                    placeholder="page_{n}"
                    description={t("tools.pdf-to-image.pattern.description")}
                    radius="md"
                  />
                </Stack>
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
                      <Folder size={20} />
                    </ThemeIcon>
                    <Box style={{ flex: 1, minWidth: 0 }}>
                      <Text
                        size="xs"
                        c="dimmed"
                        tt="uppercase"
                        fw={700}
                        lts={1}
                      >
                        {t("components.destination.output_directory")}
                      </Text>
                      <Text size="sm" fw={600} truncate="end">
                        {destDirName}
                      </Text>
                      <Text
                        size="xs"
                        c="dimmed"
                        truncate="end"
                        title={displayDestDir}
                      >
                        {parentPath}
                      </Text>
                    </Box>
                  </Group>
                  <Tooltip
                    label={t("components.destination.tooltip_dir")}
                    withArrow
                  >
                    <ActionIcon
                      variant="light"
                      color="blue"
                      size="lg"
                      radius="md"
                      onClick={handlePickDirectory}
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
