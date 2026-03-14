import {
  Paper,
  Stack,
  Text,
  Radio,
  TextInput,
  NumberInput,
  Divider,
  LoadingOverlay,
  Box,
  Group,
  ThemeIcon,
  ActionIcon,
  Tooltip,
} from "@mantine/core";
import { JSX } from "react";
import { Pencil, Folder } from "lucide-react";
import { FileItem, FileSelection } from "../components";
import { ToolPreferencesProps, TOOLS } from "../types";
import { ToolDetailShell } from "../components";
import { useSplitStore } from "./split.store";
import { SplitMode } from ".";
import { pickDirectory, pickPdfFile } from "@/services/file";

export function Split({ onBackPressed }: ToolPreferencesProps): JSX.Element {
  const splitMode = useSplitStore((s) => s.splitMode);
  const file = useSplitStore((s) => s.file);
  const selection = useSplitStore((s) => s.selection);
  const isLoading = useSplitStore((s) => s.isLoading);
  const setSplitMode = useSplitStore((s) => s.setSplitMode);
  const runSplit = useSplitStore((s) => s.runSplit);
  const setFile = useSplitStore((s) => s.setFile);
  const setSelection = useSplitStore((s) => s.setSelection);
  const removeFile = useSplitStore((s) => s.removeFile);
  const destinationDir = useSplitStore((s) => s.destinationDir);
  const setDestinationDir = useSplitStore((s) => s.setDestinationDir);

  const getDefaultDestinationDir = (filePath: string) => {
    const filename = filePath.split(/[/\\]/).pop() || "";
    return filePath.substring(0, filePath.lastIndexOf(filename));
  };

  const pickFiles = async () => {
    const selected = await pickPdfFile(false);
    if (selected && typeof selected === "string") {
      setFile(selected);
      if (!destinationDir) {
        setDestinationDir(getDefaultDestinationDir(selected));
      }
    }
  };

  const handlePickDirectory = async () => {
    const dir = await pickDirectory();
    if (dir) {
      setDestinationDir(dir);
    }
  };

  const hasFile = file !== "";
  const displayDestDir = destinationDir || (hasFile ? getDefaultDestinationDir(file) : "");
  // Get just the directory name for the bold title
  const destDirName = displayDestDir.split(/[/\\]/).filter(Boolean).pop() || displayDestDir;
  // Get the parent path for the dimmed text
  const parentPath = displayDestDir.substring(0, displayDestDir.lastIndexOf(destDirName));

  return (
    <ToolDetailShell
      tool={TOOLS.find((t) => t.id === "split")!}
      actionLabel="Split PDF"
      onAction={runSplit}
      onBackClick={onBackPressed}
      isValid={true}
    >
      <Stack gap="lg">
        <LoadingOverlay visible={isLoading} zIndex={1000} />
        <FileSelection onSelect={pickFiles} hasFiles={hasFile}>
          <FileItem file={file} onRemove={removeFile} multiple={false} />
        </FileSelection>

        <Paper withBorder p="md" radius="md">
          <Stack gap="md">
            <Text fw={600}>Split Options</Text>
            <Radio.Group
              value={splitMode}
              onChange={(value) => {
                setSplitMode(value as SplitMode);
                setSelection("");
              }}
              label="Split Mode"
              description="Choose how you want to split the document"
            >
              <Stack gap="xs" mt="xs">
                <Radio value="ranges" label="Split by Ranges" />
                <Radio
                  value="fixedSize"
                  label="Fixed Page Ranges (e.g., every 5 pages)"
                />
                <Radio value="allPages" label="Extract All Pages" />
              </Stack>
            </Radio.Group>

            <Divider />

            {splitMode === "ranges" && (
              <Stack gap="xs">
                <Text size="sm" fw={500}>
                  Page Ranges
                </Text>
                <TextInput
                  value={selection}
                  onChange={(e) => setSelection(e.currentTarget.value)}
                  placeholder="e.g. 1-5, 8-12, 15, even"
                  description="Use commas to separate ranges. Example: 1-10, 15, 20-25"
                  radius="md"
                />
              </Stack>
            )}

            {splitMode === "fixedSize" && (
              <Stack gap="xs">
                <Text size="sm" fw={500}>
                  Pages per File
                </Text>
                <NumberInput
                  value={selection !== "" ? parseInt(selection) : undefined}
                  onChange={(value) => setSelection(value?.toString() || "")}
                  min={1}
                  description="The document will be split into multiple files, each containing this many pages."
                  radius="md"
                />
              </Stack>
            )}

            {splitMode === "allPages" && (
              <Paper
                p="sm"
                bg="light-dark(var(--mantine-color-gray-0), var(--mantine-color-dark-8))"
                radius="sm"
              >
                <Text size="sm" c="dimmed">
                  Each page of the document will be saved as a separate PDF
                  file.
                </Text>
              </Paper>
            )}
          </Stack>
        </Paper>

        {hasFile && (
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
                    <Folder size={20} />
                  </ThemeIcon>
                  <Box style={{ flex: 1, minWidth: 0 }}>
                    <Text size="xs" c="dimmed" tt="uppercase" fw={700} lts={1}>
                      Output Directory
                    </Text>
                    <Text size="sm" fw={600} truncate="end">
                      {destDirName}
                    </Text>
                    <Text size="xs" c="dimmed" truncate="end" title={displayDestDir}>
                      {parentPath}
                    </Text>
                  </Box>
                </Group>
                <Tooltip label="Change directory" withArrow>
                  <ActionIcon
                    variant="light"
                    color="blue"
                    size="lg"
                    radius="md"
                    onClick={handlePickDirectory}
                  >
                    <Pencil size={18} />
                  </ActionIcon>
                </Tooltip>
              </Group>
            </Paper>
          </Stack>
        )}
      </Stack>
    </ToolDetailShell>
  );
}
