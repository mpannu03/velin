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
} from "@mantine/core";
import { JSX } from "react";
import { Save, Pencil } from "lucide-react";
import { FileItem, FileSelection } from "../components";
import { pickPdfFile, savePdfFile } from "@/services/file";
import { ToolPreferencesProps, TOOLS } from "../types";
import { ToolDetailShell } from "../components";
import { useExtractStore } from "./extract.store";

export function Extract({ onBackPressed }: ToolPreferencesProps): JSX.Element {
  const {
    file,
    selection,
    destinationPath,
    isLoading,
    setFile,
    setSelection,
    setDestinationPath,
    removeFile,
    runExtract,
  } = useExtractStore();

  const getDefaultDestination = (filePath: string) => {
    const filename = filePath.split(/[/\\]/).pop() || "";
    const path = filePath.substring(0, filePath.lastIndexOf(filename));
    const nameWithoutExt = filename.replace(/\.[^/.]+$/, "");
    return `${path}${nameWithoutExt}_extracted.pdf`;
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
      tool={TOOLS.find((t) => t.id === "extract")!}
      actionLabel="Extract Pages"
      onAction={runExtract}
      onBackClick={onBackPressed}
      isValid={hasFile && selection !== "" && !isLoading}
    >
      <Stack gap="lg" pos="relative">
        <LoadingOverlay visible={isLoading} zIndex={1000} />
        
        <FileSelection onSelect={pickFile} hasFiles={hasFile}>
          <FileItem 
            file={file} 
            onRemove={removeFile} 
            multiple={false} 
          />
        </FileSelection>

        {hasFile && (
          <Stack gap="lg">
            <Paper withBorder p="md" radius="md">
              <Stack gap="xs">
                <Text size="sm" fw={500}>
                  Pages to Extract
                </Text>
                <TextInput
                  value={selection}
                  onChange={(e) => setSelection(e.currentTarget.value)}
                  placeholder="e.g. 1-5, 8, 11-13"
                  description="Use commas to separate ranges. Example: 1-10, 15, 20-25"
                  radius="md"
                />
              </Stack>
            </Paper>

            <Stack gap="md">
              <Divider label="Output Destination" labelPosition="center" />

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
                      <Text size="xs" c="dimmed" tt="uppercase" fw={700} lts={1}>
                        Destination File
                      </Text>
                      <Text size="sm" fw={600} truncate="end">
                        {destFilename}
                      </Text>
                      <Text size="xs" c="dimmed" truncate="end" title={destDir}>
                        {destDir}
                      </Text>
                    </Box>
                  </Group>
                  <Tooltip label="Change destination" withArrow>
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
