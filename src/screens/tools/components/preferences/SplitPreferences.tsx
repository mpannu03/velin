import {
  Paper,
  Stack,
  Text,
  Radio,
  TextInput,
  NumberInput,
  Divider,
} from "@mantine/core";
import { JSX, useState } from "react";
import { FileSelection } from "./FileSelection";
import { ToolPreferencesProps } from ".";

export function SplitPreferences({
  setAction,
}: ToolPreferencesProps): JSX.Element {
  const [splitMode, setSplitMode] = useState("ranges");

  return (
    <Stack gap="lg">
      <FileSelection onSelect={() => {}} />

      <Paper withBorder p="md" radius="md">
        <Stack gap="md">
          <Text fw={600}>Split Options</Text>
          <Radio.Group
            value={splitMode}
            onChange={setSplitMode}
            label="Split Mode"
            description="Choose how you want to split the document"
          >
            <Stack gap="xs" mt="xs">
              <Radio value="ranges" label="Split by Ranges" />
              <Radio
                value="fixed"
                label="Fixed Page Ranges (e.g., every 5 pages)"
              />
              <Radio value="extract" label="Extract All Pages" />
            </Stack>
          </Radio.Group>

          <Divider />

          {splitMode === "ranges" && (
            <Stack gap="xs">
              <Text size="sm" fw={500}>
                Page Ranges
              </Text>
              <TextInput
                placeholder="e.g. 1-5, 8-12, 15"
                description="Use commas to separate ranges. Example: 1-10, 15, 20-25"
                radius="md"
              />
            </Stack>
          )}

          {splitMode === "fixed" && (
            <Stack gap="xs">
              <Text size="sm" fw={500}>
                Pages per File
              </Text>
              <NumberInput
                defaultValue={5}
                min={1}
                description="The document will be split into multiple files, each containing this many pages."
                radius="md"
              />
            </Stack>
          )}

          {splitMode === "extract" && (
            <Paper
              p="sm"
              bg="light-dark(var(--mantine-color-gray-0), var(--mantine-color-dark-8))"
              radius="sm"
            >
              <Text size="sm" c="dimmed">
                Each page of the document will be saved as a separate PDF file.
              </Text>
            </Paper>
          )}
        </Stack>
      </Paper>
    </Stack>
  );
}
