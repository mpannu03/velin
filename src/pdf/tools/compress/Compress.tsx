import {
  Badge,
  Group,
  Paper,
  Stack,
  Text,
  Slider,
  SegmentedControl,
  Divider,
  Alert,
  LoadingOverlay,
  ThemeIcon,
  Tooltip,
  ActionIcon,
  Box,
} from "@mantine/core";
import { JSX } from "react";
import { Info, Save, Pencil } from "lucide-react";
import { useTranslation } from "react-i18next";
import { FileItem, FileSelection, ToolDetailShell } from "../components";
import { ToolPreferencesProps, TOOLS } from "../types";
import { useCompressState } from "./compress.store";
import { pickPdfFile, savePdfFile } from "@/services/file";
import { CompressLevel, LEVELS } from ".";

export function Compress({ onBackPressed }: ToolPreferencesProps): JSX.Element {
  const { t } = useTranslation("tools");
  const {
    file,
    level,
    customQuality,
    destinationPath,
    isLoading,
    setFile,
    setLevel,
    setCustomQuality,
    setDestinationPath,
    runCompress,
  } = useCompressState();

  const getDefaultDestination = (sourceFile: string) => {
    const filename = sourceFile.split(/[/\\]/).pop() || "";
    const path = sourceFile.substring(0, sourceFile.lastIndexOf(filename));
    const nameWithoutExt = filename.replace(/\.[^/.]+$/, "");
    return `${path}${nameWithoutExt}_compressed.pdf`;
  };

  const pickFile = async () => {
    const selected = await pickPdfFile(false);
    if (selected && !Array.isArray(selected)) {
      setFile(selected);
      setDestinationPath(getDefaultDestination(selected));
    }
  };

  const handleSaveLocation = async () => {
    const path = await savePdfFile(destinationPath);
    if (path) {
      setDestinationPath(path);
    }
  };

  const destFilename = destinationPath.split(/[/\\]/).pop() || destinationPath;
  const destDir = destinationPath.substring(
    0,
    destinationPath.lastIndexOf(destFilename),
  );

  return (
    <ToolDetailShell
      tool={TOOLS.find((t) => t.id === "compress")!}
      actionLabel={t("tools.compress.action", { defaultValue: "Compress PDF" })}
      onAction={runCompress}
      onBackClick={onBackPressed}
      isValid={!!file && !!destinationPath && !isLoading}
    >
      <Stack gap="lg" pos="relative">
        <LoadingOverlay visible={isLoading} zIndex={1000} />

        <FileSelection onSelect={pickFile} multiple={false} hasFiles={!!file}>
          {file && (
            <Stack gap="xs">
              <FileItem
                file={file}
                onRemove={() => setFile(null)}
                showSelection={false}
              />
            </Stack>
          )}
        </FileSelection>

        {!!file && (
          <>
            <Paper withBorder p="md" radius="md">
              <Stack gap="md">
                <Text fw={600}>{t("tools.compress.levels_title")}</Text>
                <SegmentedControl
                  fullWidth
                  value={level}
                  onChange={(val) => setLevel(val as CompressLevel)}
                  data={LEVELS.map((l) => ({
                    label: t(l.labelKey as any),
                    value: l.value,
                  }))}
                  radius="md"
                  size="md"
                />

                <Alert
                  icon={<Info size={16} />}
                  title={t("tools.compress.about_title")}
                  color="blue"
                  variant="light"
                >
                  {t((LEVELS.find((l) => l.value === level)?.descriptionKey || "") as any)}
                </Alert>

                {level === "custom" && (
                  <>
                    <Divider />
                    <Stack gap="xs">
                      <Group justify="space-between">
                        <Text size="sm" fw={500}>
                          {t("tools.compress.custom_quality_title")}
                        </Text>
                        <Badge color="blue">{customQuality}%</Badge>
                      </Group>
                      <Slider
                        value={customQuality}
                        onChange={setCustomQuality}
                        marks={[
                          { value: 0, label: t("tools.compress.size_label") },
                          { value: 100, label: t("tools.compress.quality_label") },
                        ]}
                        mb="xl"
                      />
                    </Stack>
                  </>
                )}
              </Stack>
            </Paper>

            <Stack gap="md">
              <Divider
                label={t("components.destination.output_destination", {
                  defaultValue: "Save Destination",
                })}
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
                        {t("components.destination.destination_file", {
                          defaultValue: "Destination file",
                        })}
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
                    label={t("components.destination.tooltip_file", {
                      defaultValue: "Change save location",
                    })}
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
          </>
        )}
      </Stack>
    </ToolDetailShell>
  );
}
