import {
  ActionIcon,
  Box,
  Group,
  Paper,
  ThemeIcon,
  Tooltip,
  Text,
} from "@mantine/core";
import { FiFileText, FiMove, FiTrash2 } from "react-icons/fi";

interface FileItemProps {
  file: string;
  onRemove: () => void;
  dragHandleProps?: any;
  isDragging?: boolean;
}

export function FileItem({
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
          ? "light-dark(var(--mantine-primary-color-light), var(--mantine-color-dark-6))"
          : "light-dark(var(--mantine-color-white), var(--mantine-color-dark-7))",
        borderColor: isDragging
          ? "var(--mantine-primary-color-filled)"
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

          <ThemeIcon variant="light" size="lg" radius="md">
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
