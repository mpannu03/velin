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
  SegmentedControl,
  Center,
} from "@mantine/core";
import { JSX } from "react";
import { Save, Pencil, RotateCw, RotateCcw, RefreshCw } from "lucide-react";
import { useTranslation } from "react-i18next";
import { FileItem, FileSelection } from "../components";
import { pickPdfFile, savePdfFile } from "@/services/file";
import { ToolPreferencesProps, TOOLS } from "../types";
import { ToolDetailShell } from "../components";
import { useRotateStore } from "./rotate.store";

export function Rotate({ onBackPressed }: ToolPreferencesProps): JSX.Element {
  const { t } = useTranslation("tools");
  const {
    file,
    selection,
    pagesMode,
    destinationPath,
    angle,
    isLoading,
    setFile,
    setSelection,
    setPagesMode,
    setDestinationPath,
    setAngle,
    removeFile,
    runRotate,
  } = useRotateStore();

  const getDefaultDestination = (filePath: string) => {
    const filename = filePath.split(/[/\\]/).pop() || "";
    const path = filePath.substring(0, filePath.lastIndexOf(filename));
    const nameWithoutExt = filename.replace(/\.[^/.]+$/, "");
    return `${path}${nameWithoutExt}_rotated.pdf`;
  };

  const pickFile = async () => {
    const selected = await pickPdfFile(false);
    if (selected && typeof selected === "string") {
      setFile(selected);
      if (!destinationPath) {
        setDestinationPath(getDefaultDestination(selected));
      }
    }
  };

  const handleSaveLocation = async () => {
    const path = await savePdfFile(destinationPath);
    if (path) {
      setDestinationPath(path);
    }
  };

  const hasFile = file !== "";
  const destFilename = destinationPath.split(/[/\\]/).pop() || destinationPath;
  const destDir = destinationPath.substring(
    0,
    destinationPath.lastIndexOf(destFilename),
  );

  return (
    <ToolDetailShell
      tool={TOOLS.find((t) => t.id === "rotate")!}
      actionLabel={t("tools.rotate.action")}
      onAction={runRotate}
      onBackClick={onBackPressed}
      isValid={hasFile && (pagesMode === "all" || selection !== "") && !isLoading}
    >
      <Stack gap="lg" pos="relative">
        <LoadingOverlay visible={isLoading} zIndex={1000} />

        <FileSelection onSelect={pickFile} hasFiles={hasFile} toolId="rotate">
          <FileItem file={file} onRemove={removeFile} multiple={false} />
        </FileSelection>

        {hasFile && (
          <Stack gap="lg">
            <Paper withBorder p="md" radius="md">
              <Stack gap="md">
                <Text size="sm" fw={600}>
                  {t("tools.rotate.angle.label")}
                </Text>
                <SegmentedControl
                  value={angle.toString()}
                  onChange={(val) => setAngle(parseInt(val))}
                  data={[
                    {
                      value: "90",
                      label: (
                        <Center style={{ gap: 8 }}>
                          <RotateCw size={16} />
                          <span>{t("tools.rotate.angle.right")}</span>
                        </Center>
                      ),
                    },
                    {
                      value: "180",
                      label: (
                        <Center style={{ gap: 8 }}>
                          <RefreshCw size={16} />
                          <span>{t("tools.rotate.angle.half")}</span>
                        </Center>
                      ),
                    },
                    {
                      value: "270",
                      label: (
                        <Center style={{ gap: 8 }}>
                          <RotateCcw size={16} />
                          <span>{t("tools.rotate.angle.left")}</span>
                        </Center>
                      ),
                    },
                  ]}
                  radius="md"
                  fullWidth
                />
              </Stack>
            </Paper>

            <Paper withBorder p="md" radius="md">
              <Stack gap="md">
                <Text size="sm" fw={600}>
                  {t("tools.rotate.pages_to_rotate.label")}
                </Text>
                <SegmentedControl
                  value={pagesMode}
                  onChange={(val) => setPagesMode(val as "all" | "select")}
                  data={[
                    { label: t("tools.rotate.pages_to_rotate.all"), value: "all" },
                    { label: t("tools.rotate.pages_to_rotate.select"), value: "select" },
                  ]}
                  radius="md"
                  fullWidth
                />

                {pagesMode === "select" && (
                  <Stack gap="xs" mt="xs">
                    <TextInput
                      value={selection}
                      onChange={(e) => setSelection(e.currentTarget.value)}
                      placeholder={t("components.file_item.selection_placeholder")}
                      description={t("tools.rotate.pages_to_rotate.selection_description")}
                      radius="md"
                    />
                  </Stack>
                )}
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
