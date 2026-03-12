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
import { Plus, CloudUpload } from "lucide-react";

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
                ? "Select PDF files to merge"
                : "Select a PDF file to process"}
            </Text>
            <Text size="sm" c="dimmed" maw={300} mx="auto">
              Drag and drop your PDF files here or click anywhere in this area
              to browse
            </Text>
          </Box>

          <Button
            leftSection={<Plus size={20} />}
            radius="md"
            size="md"
            variant={hovered ? "filled" : "light"}
            style={{ transition: "all 0.2s ease" }}
          >
            {multiple ? "Add PDF Files" : "Select PDF"}
          </Button>
        </Stack>
      ) : (
        <Stack gap="md">
          <Group justify="space-between" px="xs">
            <Text fw={700} size="sm" c="dimmed" tt="uppercase" lts={1}>
              Files to Process
            </Text>
            <Button
              variant="subtle"
              size="xs"
              leftSection={<Plus size={14} />}
              onClick={onSelect}
            >
              Add More
            </Button>
          </Group>

          <Box px="xs" pb="xs">
            {children}
          </Box>

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
              Drop more files here or click to add
            </Text>
          </Box>
        </Stack>
      )}
    </Paper>
  );
}
