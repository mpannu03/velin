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
  Slider,
  Badge,
  Button,
  Alert,
  NumberInput,
  SimpleGrid,
} from "@mantine/core";
import { JSX } from "react";
import {
  Save,
  Pencil,
  Type,
  Image,
  RotateCw,
  Droplets,
  AlignCenterHorizontal,
  AlignStartHorizontal,
  AlignEndHorizontal,
  AlignStartVertical,
  AlignEndVertical,
  MoveHorizontal,
  MoveVertical,
  AlertTriangle,
} from "lucide-react";
import { useTranslation } from "react-i18next";
import { FileSelection } from "../components";
import { ToolPreferencesProps, TOOLS } from "../types";
import { ToolDetailShell } from "../components";
import {
  useWatermarkStore,
  WatermarkType,
  WatermarkPosition,
} from "./watermark.store";
import { pickPdfFile, savePdfFile, pickImageFiles } from "@/services/file";

const WATERMARK_POSITIONS: {
  value: WatermarkPosition;
  label: string;
  icon: JSX.Element;
}[] = [
  {
    value: "center",
    label: "Center",
    icon: <AlignCenterHorizontal size={16} />,
  },
  {
    value: "top-left",
    label: "Top Left",
    icon: <AlignStartVertical size={16} />,
  },
  {
    value: "top-right",
    label: "Top Right",
    icon: <AlignEndVertical size={16} />,
  },
  {
    value: "bottom-left",
    label: "Bottom Left",
    icon: <AlignStartHorizontal size={16} />,
  },
  {
    value: "bottom-right",
    label: "Bottom Right",
    icon: <AlignEndHorizontal size={16} />,
  },
];

const ROTATION_OPTIONS = [
  { value: "0", label: "0°" },
  { value: "45", label: "45°" },
  { value: "90", label: "90°" },
  { value: "-45", label: "-45°" },
  { value: "-90", label: "-90°" },
];

export function Watermark({
  onBackPressed,
}: ToolPreferencesProps): JSX.Element {
  const { t } = useTranslation("tools");
  const {
    file,
    destinationPath,
    watermarkType,
    text,
    fontSize,
    fontColor,
    imagePath,
    imageScale,
    opacity,
    rotation,
    position,
    xOffset,
    yOffset,
    pagesMode,
    pageSelection,
    isLoading,
    setFile,
    setDestinationPath,
    setWatermarkType,
    setText,
    setFontSize,
    setFontColor,
    setImagePath,
    setImageScale,
    setOpacity,
    setRotation,
    setPosition,
    setXOffset,
    setYOffset,
    setPagesMode,
    setPageSelection,
    runWatermark,
  } = useWatermarkStore();

  const hasFile = !!file;
  const hasText = watermarkType === "text" ? text.trim().length > 0 : true;
  const hasImage = watermarkType === "image" ? !!imagePath : true;

  const getDefaultDestination = (filePath: string) => {
    const filename = filePath.split(/[/\\]/).pop() || "";
    const path = filePath.substring(0, filePath.lastIndexOf(filename));
    const nameWithoutExt = filename.replace(/\.[^/.]+$/, "");
    return `${path}${nameWithoutExt}_watermarked.pdf`;
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

  const pickWatermarkImage = async () => {
    const selected = await pickImageFiles(false);
    if (selected && typeof selected === "string") {
      setImagePath(selected);
    }
  };

  const destFilename = destinationPath.split(/[/\\]/).pop() || destinationPath;
  const destDir = destinationPath.substring(
    0,
    destinationPath.lastIndexOf(destFilename),
  );

  return (
    <ToolDetailShell
      tool={TOOLS.find((t) => t.id === "watermark")!}
      actionLabel={t("tools.watermark.action", {
        defaultValue: "Add Watermark",
      })}
      onAction={runWatermark}
      onBackClick={onBackPressed}
      isValid={
        hasFile && hasText && hasImage && !!destinationPath && !isLoading
      }
    >
      <Stack gap="lg" pos="relative">
        <LoadingOverlay visible={isLoading} zIndex={1000} />

        <FileSelection
          onSelect={pickFile}
          hasFiles={hasFile}
          toolId="watermark"
        >
          {file && (
            <Box>
              <Text fw={600} truncate="end">
                {file.split(/[/\\]/).pop() || file}
              </Text>
            </Box>
          )}
        </FileSelection>

        {hasFile && (
          <>
            {/* Watermark Type Selection */}
            <Paper withBorder p="md" radius="md">
              <Stack gap="md">
                <Text size="sm" fw={600}>
                  {t("tools.watermark.type_label", {
                    defaultValue: "Watermark Type",
                  })}
                </Text>
                <SegmentedControl
                  fullWidth
                  value={watermarkType}
                  onChange={(val) => setWatermarkType(val as WatermarkType)}
                  data={[
                    {
                      value: "text",
                      label: (
                        <Center style={{ gap: 8 }}>
                          <Type size={16} />
                          <span>
                            {t("tools.watermark.type_text", {
                              defaultValue: "Text",
                            })}
                          </span>
                        </Center>
                      ),
                    },
                    {
                      value: "image",
                      label: (
                        <Center style={{ gap: 8 }}>
                          <Image size={16} />
                          <span>
                            {t("tools.watermark.type_image", {
                              defaultValue: "Image",
                            })}
                          </span>
                        </Center>
                      ),
                    },
                  ]}
                  radius="md"
                  size="md"
                />
              </Stack>
            </Paper>

            {/* Text Watermark Options */}
            {watermarkType === "text" && (
              <Paper withBorder p="md" radius="md">
                <Stack gap="md">
                  <Text size="sm" fw={600}>
                    {t("tools.watermark.text_options", {
                      defaultValue: "Text Options",
                    })}
                  </Text>
                  <TextInput
                    value={text}
                    onChange={(e) => setText(e.currentTarget.value)}
                    placeholder={t("tools.watermark.text_placeholder", {
                      defaultValue: "Enter watermark text...",
                    })}
                    leftSection={<Type size={16} />}
                    radius="md"
                  />
                  <SimpleGrid cols={2} spacing="md">
                    <Stack gap="xs">
                      <Group justify="space-between">
                        <Text size="sm">
                          {t("tools.watermark.font_size", {
                            defaultValue: "Font Size",
                          })}
                        </Text>
                        <Badge color="blue" size="sm">
                          {fontSize}px
                        </Badge>
                      </Group>
                      <Slider
                        value={fontSize}
                        onChange={setFontSize}
                        min={12}
                        max={120}
                        marks={[
                          { value: 12, label: "12" },
                          { value: 48, label: "48" },
                          { value: 120, label: "120" },
                        ]}
                      />
                    </Stack>
                    <Stack gap="xs">
                      <Text size="sm">
                        {t("tools.watermark.color", { defaultValue: "Color" })}
                      </Text>
                      <Group gap="xs" wrap="wrap">
                        {[
                          "#808080",
                          "#000000",
                          "#FF0000",
                          "#0000FF",
                          "#008000",
                          "#FFA500",
                          "#800080",
                          "#FFC0CB",
                        ].map((color) => (
                          <Box
                            key={color}
                            onClick={() => setFontColor(color)}
                            style={{
                              width: 32,
                              height: 32,
                              borderRadius: 8,
                              backgroundColor: color,
                              cursor: "pointer",
                              border:
                                fontColor === color
                                  ? "3px solid var(--mantine-primary-color-filled)"
                                  : "2px solid var(--mantine-color-default-border)",
                              transition: "all 0.15s ease",
                              transform:
                                fontColor === color ? "scale(1.1)" : "scale(1)",
                            }}
                          />
                        ))}
                      </Group>
                    </Stack>
                  </SimpleGrid>
                </Stack>
              </Paper>
            )}

            {/* Image Watermark Options */}
            {watermarkType === "image" && (
              <Paper withBorder p="md" radius="md">
                <Stack gap="md">
                  <Text size="sm" fw={600}>
                    {t("tools.watermark.image_options", {
                      defaultValue: "Image Options",
                    })}
                  </Text>
                  {!imagePath ? (
                    <Paper
                      withBorder
                      p="xl"
                      radius="md"
                      style={{
                        borderStyle: "dashed",
                        borderWidth: 2,
                        cursor: "pointer",
                        textAlign: "center",
                        transition: "all 0.2s ease",
                      }}
                      onClick={pickWatermarkImage}
                    >
                      <Stack align="center" gap="sm">
                        <ThemeIcon variant="light" size={48} radius="50%">
                          <Image size={24} />
                        </ThemeIcon>
                        <Text size="sm" c="dimmed">
                          {t("tools.watermark.select_image", {
                            defaultValue: "Click to select watermark image",
                          })}
                        </Text>
                        <Button size="xs" variant="light" radius="md">
                          {t("tools.watermark.browse_image", {
                            defaultValue: "Browse",
                          })}
                        </Button>
                      </Stack>
                    </Paper>
                  ) : (
                    <Stack gap="sm">
                      <Group justify="space-between" wrap="nowrap">
                        <Group
                          gap="md"
                          wrap="nowrap"
                          style={{ flex: 1, minWidth: 0 }}
                        >
                          <ThemeIcon variant="light" size="lg" radius="md">
                            <Image size={20} />
                          </ThemeIcon>
                          <Box style={{ flex: 1, minWidth: 0 }}>
                            <Text size="sm" fw={600} truncate="end">
                              {imagePath.split(/[/\\]/).pop() || imagePath}
                            </Text>
                          </Box>
                        </Group>
                        <Button
                          variant="subtle"
                          size="xs"
                          leftSection={<Pencil size={14} />}
                          onClick={pickWatermarkImage}
                        >
                          {t("tools.watermark.change_image", {
                            defaultValue: "Change",
                          })}
                        </Button>
                      </Group>
                      <Stack gap="xs">
                        <Group justify="space-between">
                          <Text size="sm">
                            {t("tools.watermark.image_scale", {
                              defaultValue: "Scale",
                            })}
                          </Text>
                          <Badge color="blue" size="sm">
                            {Math.round(imageScale * 100)}%
                          </Badge>
                        </Group>
                        <Slider
                          value={imageScale * 100}
                          onChange={(val) => setImageScale(val / 100)}
                          min={5}
                          max={200}
                          marks={[
                            { value: 5, label: "5%" },
                            { value: 50, label: "50%" },
                            { value: 100, label: "100%" },
                            { value: 200, label: "200%" },
                          ]}
                        />
                      </Stack>
                    </Stack>
                  )}
                </Stack>
              </Paper>
            )}

            {/* Opacity & Rotation */}
            <Paper withBorder p="md" radius="md">
              <Stack gap="md">
                <SimpleGrid cols={2} spacing="md">
                  <Stack gap="xs">
                    <Group justify="space-between">
                      <Group gap={4}>
                        <Droplets size={14} />
                        <Text size="sm">
                          {t("tools.watermark.opacity", {
                            defaultValue: "Opacity",
                          })}
                        </Text>
                      </Group>
                      <Badge color="blue" size="sm">
                        {Math.round(opacity * 100)}%
                      </Badge>
                    </Group>
                    <Slider
                      value={opacity * 100}
                      onChange={(val) => setOpacity(val / 100)}
                      min={5}
                      max={100}
                      marks={[
                        { value: 5, label: "5%" },
                        { value: 50, label: "50%" },
                        { value: 100, label: "100%" },
                      ]}
                    />
                  </Stack>
                  <Stack gap="xs">
                    <Group gap={4}>
                      <RotateCw size={14} />
                      <Text size="sm">
                        {t("tools.watermark.rotation", {
                          defaultValue: "Rotation",
                        })}
                      </Text>
                    </Group>
                    <SegmentedControl
                      fullWidth
                      value={rotation.toString()}
                      onChange={(val) => setRotation(parseInt(val))}
                      data={ROTATION_OPTIONS.map((opt) => ({
                        value: opt.value,
                        label: opt.label,
                      }))}
                      radius="md"
                      size="xs"
                    />
                  </Stack>
                </SimpleGrid>
              </Stack>
            </Paper>

            {/* Position & Offset */}
            <Paper withBorder p="md" radius="md">
              <Stack gap="md">
                <Text size="sm" fw={600}>
                  {t("tools.watermark.position", { defaultValue: "Position" })}
                </Text>
                <SimpleGrid cols={5} spacing="xs">
                  {WATERMARK_POSITIONS.map((pos) => (
                    <Paper
                      key={pos.value}
                      withBorder
                      p="xs"
                      radius="md"
                      style={{
                        cursor: "pointer",
                        textAlign: "center",
                        borderColor:
                          position === pos.value
                            ? "var(--mantine-primary-color-filled)"
                            : undefined,
                        backgroundColor:
                          position === pos.value
                            ? "light-dark(var(--mantine-primary-color-light), var(--mantine-color-dark-6))"
                            : undefined,
                        transition: "all 0.15s ease",
                      }}
                      onClick={() =>
                        setPosition(pos.value as WatermarkPosition)
                      }
                    >
                      <Center style={{ flexDirection: "column", gap: 4 }}>
                        {pos.icon}
                        <Text size="xs" fw={500}>
                          {pos.label}
                        </Text>
                      </Center>
                    </Paper>
                  ))}
                </SimpleGrid>

                <SimpleGrid cols={2} spacing="md">
                  <Stack gap="xs">
                    <Group gap={4}>
                      <MoveHorizontal size={14} />
                      <Text size="sm">
                        {t("tools.watermark.x_offset", {
                          defaultValue: "X Offset",
                        })}
                      </Text>
                    </Group>
                    <NumberInput
                      value={xOffset}
                      onChange={(val) => setXOffset(Number(val) || 0)}
                      min={-200}
                      max={200}
                      radius="md"
                      size="sm"
                    />
                  </Stack>
                  <Stack gap="xs">
                    <Group gap={4}>
                      <MoveVertical size={14} />
                      <Text size="sm">
                        {t("tools.watermark.y_offset", {
                          defaultValue: "Y Offset",
                        })}
                      </Text>
                    </Group>
                    <NumberInput
                      value={yOffset}
                      onChange={(val) => setYOffset(Number(val) || 0)}
                      min={-200}
                      max={200}
                      radius="md"
                      size="sm"
                    />
                  </Stack>
                </SimpleGrid>
              </Stack>
            </Paper>

            {/* Page Selection */}
            <Paper withBorder p="md" radius="md">
              <Stack gap="md">
                <Text size="sm" fw={600}>
                  {t("tools.watermark.pages_label", { defaultValue: "Pages" })}
                </Text>
                <SegmentedControl
                  fullWidth
                  value={pagesMode}
                  onChange={(val) => setPagesMode(val as "all" | "select")}
                  data={[
                    {
                      value: "all",
                      label: t("tools.watermark.all_pages", {
                        defaultValue: "All Pages",
                      }),
                    },
                    {
                      value: "select",
                      label: t("tools.watermark.select_pages", {
                        defaultValue: "Specific Pages",
                      }),
                    },
                  ]}
                  radius="md"
                  size="md"
                />
                {pagesMode === "select" && (
                  <TextInput
                    value={pageSelection}
                    onChange={(e) => setPageSelection(e.currentTarget.value)}
                    placeholder={t(
                      "components.file_item.selection_placeholder",
                    )}
                    description={t(
                      "tools.watermark.page_selection_description",
                      {
                        defaultValue:
                          "Use commas to separate ranges. Example: 1-10, 15, 20-25",
                      },
                    )}
                    radius="md"
                  />
                )}
              </Stack>
            </Paper>

            {/* Info Alert */}
            <Alert
              icon={<AlertTriangle size={16} />}
              title={t("tools.watermark.info_title", {
                defaultValue: "About Watermarking",
              })}
              color="blue"
              variant="light"
            >
              {t("tools.watermark.info_desc", {
                defaultValue:
                  "The watermark will be added as an overlay on the selected pages. Text watermarks use Helvetica font. Image watermarks are embedded as JPEG at 85% quality.",
              })}
            </Alert>

            {/* Destination */}
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
