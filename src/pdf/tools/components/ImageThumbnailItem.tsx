import {
  ActionIcon,
  AspectRatio,
  Box,
  Group,
  Image,
  Paper,
  Skeleton,
  Text,
  Tooltip,
} from "@mantine/core";
import { Move, Trash2 } from "lucide-react";
import { useTranslation } from "react-i18next";
import { useEffect, useState } from "react";
import { convertFileSrc } from "@tauri-apps/api/core";

interface ImageThumbnailItemProps {
  file: string;
  onRemove: () => void;
  dragHandleProps?: any;
  isDragging?: boolean;
  viewMode?: "list" | "grid";
}

export function ImageThumbnailItem({
  file,
  onRemove,
  dragHandleProps,
  isDragging,
  viewMode = "list",
}: ImageThumbnailItemProps) {
  const { t } = useTranslation("tools");
  const [imageSrc, setImageSrc] = useState<string | null>(null);
  const [loaded, setLoaded] = useState(false);
  const [error, setError] = useState(false);

  const filename = file.split(/[/\\]/).pop() || file;

  useEffect(() => {
    try {
      const src = convertFileSrc(file);
      setImageSrc(src);
    } catch {
      // If convertFileSrc fails, try direct path
      setImageSrc(`asset://localhost/${file.replace(/\\/g, "/")}`);
    }
  }, [file]);

  if (viewMode === "grid") {
    return (
      <Paper
        withBorder
        p="xs"
        radius="md"
        shadow={isDragging ? "md" : "xs"}
        style={{
          backgroundColor: isDragging
            ? "light-dark(var(--mantine-primary-color-light), var(--mantine-color-dark-6))"
            : "light-dark(var(--mantine-color-white), var(--mantine-color-dark-7))",
          borderColor: isDragging
            ? "var(--mantine-primary-color-filled)"
            : undefined,
          position: "relative",
          transition: "all 0.2s ease",
        }}
      >
        <AspectRatio ratio={1} mb={4}>
          {!loaded && !error && (
            <Skeleton width="100%" height="100%" radius="sm" />
          )}
          {error ? (
            <Box
              w="100%"
              h="100%"
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                borderRadius: "var(--mantine-radius-sm)",
                backgroundColor:
                  "light-dark(var(--mantine-color-gray-1), var(--mantine-color-dark-6))",
              }}
            >
              <Text size="xs" c="dimmed" ta="center" px={4}>
                {filename}
              </Text>
            </Box>
          ) : (
            <Image
              src={imageSrc}
              alt={filename}
              fit="cover"
              radius="sm"
              style={{ opacity: loaded ? 1 : 0 }}
              onLoad={() => setLoaded(true)}
              onError={() => setError(true)}
            />
          )}
        </AspectRatio>

        <Group justify="center" gap={4}>
          <Tooltip
            label={t("components.file_item.drag_tooltip")}
            position="top"
            withArrow
          >
            <ActionIcon
              variant="subtle"
              color="gray"
              size="sm"
              style={{ cursor: "grab" }}
              {...dragHandleProps}
            >
              <Move size={14} />
            </ActionIcon>
          </Tooltip>
          <Text size="xs" truncate="end" style={{ flex: 1 }} ta="center">
            {filename}
          </Text>
          <Tooltip
            label={t("components.file_item.remove_tooltip")}
            position="top"
            withArrow
          >
            <ActionIcon
              variant="subtle"
              color="red"
              size="sm"
              onClick={onRemove}
            >
              <Trash2 size={14} />
            </ActionIcon>
          </Tooltip>
        </Group>
      </Paper>
    );
  }

  // List view (default) — thumbnail with details
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
      <Group gap="md" wrap="nowrap">
        <Tooltip label={t("components.file_item.drag_tooltip")} withArrow>
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

        <Box
          w={64}
          h={64}
          style={{
            borderRadius: "var(--mantine-radius-sm)",
            overflow: "hidden",
            flexShrink: 0,
            backgroundColor:
              "light-dark(var(--mantine-color-gray-1), var(--mantine-color-dark-6))",
          }}
        >
          {!loaded && !error && <Skeleton width={64} height={64} radius="sm" />}
          {error ? (
            <Box
              w={64}
              h={64}
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <Text size="xs" c="dimmed" ta="center">
                🖼️
              </Text>
            </Box>
          ) : (
            <Image
              src={imageSrc}
              alt={filename}
              fit="cover"
              w={64}
              h={64}
              style={{ opacity: loaded ? 1 : 0 }}
              onLoad={() => setLoaded(true)}
              onError={() => setError(true)}
            />
          )}
        </Box>

        <Box style={{ flex: 1, minWidth: 0 }}>
          <Text size="sm" fw={600} truncate="end">
            {filename}
          </Text>
          <Text size="xs" c="dimmed" truncate="end" title={file}>
            {file.substring(0, file.lastIndexOf(filename))}
          </Text>
        </Box>

        <Tooltip label={t("components.file_item.remove_tooltip")} withArrow>
          <ActionIcon variant="subtle" color="red" onClick={onRemove} size="md">
            <Trash2 size={18} />
          </ActionIcon>
        </Tooltip>
      </Group>
    </Paper>
  );
}
