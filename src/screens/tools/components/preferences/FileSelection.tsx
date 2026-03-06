import {
  Button,
  Center,
  Paper,
  Stack,
  Text,
  ThemeIcon,
  Box,
} from "@mantine/core";
import { JSX } from "react";
import { FiPlus, FiUploadCloud } from "react-icons/fi";

interface FileSelectionProps {
  onSelect: () => void;
  multiple?: boolean;
}

export function FileSelection({
  onSelect,
  multiple = false,
}: FileSelectionProps): JSX.Element {
  return (
    <Paper
      p="xl"
      radius="md"
      withBorder
      style={{
        borderStyle: "dashed",
        borderWidth: 2,
        backgroundColor:
          "light-dark(var(--mantine-color-gray-0), var(--mantine-color-dark-8))",
      }}
    >
      <Center py="xl">
        <Stack align="center" gap="md">
          <ThemeIcon size={64} radius="xl" variant="light" color="blue">
            <FiUploadCloud size={32} />
          </ThemeIcon>
          <Box style={{ textAlign: "center" }}>
            <Text fw={500} size="lg">
              {multiple
                ? "Select PDF files to process"
                : "Select a PDF file to process"}
            </Text>
            <Text size="sm" c="dimmed">
              Drag and drop files here or click the button below
            </Text>
          </Box>
          <Button
            leftSection={<FiPlus size={18} />}
            radius="md"
            onClick={onSelect}
          >
            {multiple ? "Add Files" : "Select File"}
          </Button>
        </Stack>
      </Center>
    </Paper>
  );
}
