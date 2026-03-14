import {
  ActionIcon,
  Box,
  Group,
  Paper,
  ThemeIcon,
  Tooltip,
  Text,
  TextInput,
  Stack,
} from "@mantine/core";
import { FileText, Move, Trash2, Settings } from "lucide-react";
import { useTranslation } from "react-i18next";

interface FileItemProps {
  file: string;
  selection?: string | null;
  onSelectionChange?: (selection: string) => void;
  onRemove: () => void;
  dragHandleProps?: any;
  isDragging?: boolean;
  multiple?: boolean;
  showSelection?: boolean;
}

export function FileItem({
  file,
  selection,
  onSelectionChange,
  onRemove,
  dragHandleProps,
  isDragging,
  multiple = true,
  showSelection = false,
}: FileItemProps) {
  const { t } = useTranslation("tools");
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
          ? "light-dark(var(--mantine-primary-color-light), var(--mantine-color-dark-6))"
          : "light-dark(var(--mantine-color-white), var(--mantine-color-dark-7))",
        borderColor: isDragging
          ? "var(--mantine-primary-color-filled)"
          : undefined,
        cursor: "default",
        transition: "all 0.2s ease",
      }}
    >
      <Stack gap="xs">
        <Group justify="space-between" wrap="nowrap">
          <Group gap="md" wrap="nowrap" style={{ flex: 1 }}>
            {multiple && (
              <Tooltip label={t("components.file_item.drag_tooltip")} position="left" withArrow>
                <ActionIcon
                  variant="subtle"
                  color="gray"
                  size="md"
                  style={{ cursor: "grab" }}
                  {...dragHandleProps}
                >
                  <Move size={18} />
                </ActionIcon>
              </Tooltip>
            )}

            <ThemeIcon variant="light" size="lg" radius="md">
              <FileText size={20} />
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

          <Tooltip label={t("components.file_item.remove_tooltip")} withArrow>
            <ActionIcon
              variant="subtle"
              color="red"
              onClick={onRemove}
              size="md"
            >
              <Trash2 size={18} />
            </ActionIcon>
          </Tooltip>
        </Group>

        {showSelection && (
          <TextInput
            size="xs"
            placeholder={t("components.file_item.selection_placeholder")}
            leftSection={<Settings size={14} />}
            value={selection || ""}
            onChange={(e) => onSelectionChange?.(e.currentTarget.value)}
            styles={{
              input: {
                backgroundColor:
                  "light-dark(var(--mantine-color-gray-0), var(--mantine-color-dark-8))",
              },
            }}
          />
        )}
      </Stack>
    </Paper>
  );
}
