import {
  Badge,
  CloseButton,
  Group,
  Paper,
  Stack,
  Text,
  ThemeIcon,
  ActionIcon,
} from "@mantine/core";
import { JSX } from "react";
import { FiFileText, FiMove } from "react-icons/fi";
import { FileSelection } from "./FileSelection";

export function MergePreferences(): JSX.Element {
  // Mock data for UI
  const files = [
    { name: "Summary_Report_Q4.pdf", size: "2.4 MB", pages: 12 },
    { name: "Financial_Highlights.pdf", size: "1.1 MB", pages: 5 },
    { name: "Project_Plan_V2.pdf", size: "3.7 MB", pages: 20 },
  ];

  return (
    <Stack gap="lg">
      <FileSelection onSelect={() => {}} multiple />

      <Stack gap="sm">
        <Group justify="space-between">
          <Text fw={600}>Selected Files (3)</Text>
          <Text size="xs" c="dimmed">
            Drag to reorder
          </Text>
        </Group>

        {files.map((file, index) => (
          <Paper
            key={index}
            withBorder
            p="sm"
            radius="md"
            style={{
              backgroundColor:
                "light-dark(var(--mantine-color-white), var(--mantine-color-dark-7))",
              cursor: "default",
            }}
          >
            <Group justify="space-between">
              <Group gap="md">
                <ActionIcon
                  variant="subtle"
                  color="gray"
                  size="sm"
                  style={{ cursor: "grab" }}
                >
                  <FiMove size={16} />
                </ActionIcon>
                <ThemeIcon variant="light" color="blue" size="md">
                  <FiFileText size={16} />
                </ThemeIcon>
                <Box>
                  <Text size="sm" fw={500}>
                    {file.name}
                  </Text>
                  <Group gap="xs">
                    <Text size="xs" c="dimmed">
                      {file.size}
                    </Text>
                    <Text size="xs" c="dimmed">
                      •
                    </Text>
                    <Text size="xs" c="dimmed">
                      {file.pages} pages
                    </Text>
                  </Group>
                </Box>
              </Group>
              <CloseButton size="sm" />
            </Group>
          </Paper>
        ))}
      </Stack>

      <Paper
        p="md"
        radius="md"
        withBorder
        bg="var(--mantine-primary-color-light)"
      >
        <Stack gap="xs">
          <Text fw={500} size="sm">
            Merge Settings
          </Text>
          <Group gap="md">
            <Badge variant="dot" color="blue">
              Optimized for Web
            </Badge>
            <Badge variant="dot" color="green">
              Keep Metadata
            </Badge>
          </Group>
        </Stack>
      </Paper>
    </Stack>
  );
}

import { Box } from "@mantine/core";
