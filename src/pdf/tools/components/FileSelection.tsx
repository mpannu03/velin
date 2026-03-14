import {
  Button,
  Paper,
  Stack,
  Text,
  ThemeIcon,
  Box,
  Group,
} from "@mantine/core";
import { JSX, useState, ReactNode } from "react";
import { Plus, CloudUpload, RefreshCw } from "lucide-react";
import { useTranslation } from "react-i18next";

interface FileSelectionProps {
  onSelect: () => void;
  multiple?: boolean;
  children?: ReactNode;
  hasFiles?: boolean;
}

export function FileSelection({
  onSelect,
  multiple = false,
  children,
  hasFiles = false,
}: FileSelectionProps): JSX.Element {
  const { t } = useTranslation("tools");
  const [hovered, setHovered] = useState(false);

  return (
    <Paper
      p={hasFiles ? "md" : "xl"}
      radius="lg"
      withBorder
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      style={{
        borderStyle: "dashed",
        borderWidth: 2,
        borderColor: hovered
          ? "var(--mantine-primary-color-filled)"
          : undefined,
        backgroundColor: hovered
          ? "light-dark(var(--mantine-primary-color-light), var(--mantine-color-dark-8))"
          : "light-dark(var(--mantine-color-gray-0), var(--mantine-color-dark-9))",
        transition: "all 0.2s ease",
        minHeight: hasFiles ? "auto" : 300,
        display: "flex",
        flexDirection: "column",
        cursor: hasFiles ? "default" : "pointer",
      }}
      onClick={!hasFiles ? onSelect : undefined}
    >
      {!hasFiles ? (
        <Stack
          align="center"
          gap="lg"
          py="xl"
          style={{ pointerEvents: "none", flex: 1, justifyContent: "center" }}
        >
          <ThemeIcon
            size={80}
            radius="100%"
            variant={hovered ? "filled" : "light"}
            style={{
              transition: "all 0.3s ease",
              transform: hovered ? "scale(1.05)" : "scale(1)",
            }}
          >
            <CloudUpload size={40} />
          </ThemeIcon>

          <Box style={{ textAlign: "center" }}>
            <Text fw={700} size="xl" mb={4}>
              {multiple
                ? t("components.file_selection.title_multiple")
                : t("components.file_selection.title_single")}
            </Text>
            <Text size="sm" c="dimmed" maw={300} mx="auto">
              {t("components.file_selection.description")}
            </Text>
          </Box>

          <Button
            leftSection={<Plus size={20} />}
            radius="md"
            size="md"
            variant={hovered ? "filled" : "light"}
            style={{ transition: "all 0.2s ease" }}
          >
            {multiple
              ? t("components.file_selection.button_multiple")
              : t("components.file_selection.button_single")}
          </Button>
        </Stack>
      ) : (
        <Stack gap="md">
          <Group justify="space-between" px="xs">
            <Text fw={700} size="sm" c="dimmed" tt="uppercase" lts={1}>
              {multiple
                ? t("components.file_selection.label_multiple")
                : t("components.file_selection.label_single")}
            </Text>
            <Button
              variant="subtle"
              size="xs"
              leftSection={
                multiple ? <Plus size={14} /> : <RefreshCw size={14} />
              }
              onClick={onSelect}
            >
              {multiple
                ? t("components.file_selection.add_more")
                : t("components.file_selection.change_file")}
            </Button>
          </Group>

          <Box px="xs" pb="xs">
            {children}
          </Box>

          {multiple && (
            <Box
              p="sm"
              style={{
                borderTop: "1px dashed var(--mantine-color-default-border)",
                textAlign: "center",
                cursor: "pointer",
                borderRadius:
                  "0 0 var(--mantine-radius-lg) var(--mantine-radius-lg)",
              }}
              onClick={onSelect}
              onMouseEnter={(e) =>
                (e.currentTarget.style.backgroundColor =
                  "var(--mantine-primary-color-light)")
              }
              onMouseLeave={(e) =>
                (e.currentTarget.style.backgroundColor = "transparent")
              }
            >
              <Text size="xs" fw={500} c="dimmed">
                {t("components.file_selection.drop_more")}
              </Text>
            </Box>
          )}
        </Stack>
      )}
    </Paper>
  );
}
