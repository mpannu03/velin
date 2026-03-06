import {
  Badge,
  Group,
  Paper,
  Stack,
  Text,
  Slider,
  SegmentedControl,
  Divider,
  Select,
} from "@mantine/core";
import { JSX, useState } from "react";
import { FileSelection } from "./FileSelection";

export function ImagePreferences({ title }: { title: string }): JSX.Element {
  const [format, setFormat] = useState("jpg");

  return (
    <Stack gap="lg">
      <FileSelection onSelect={() => {}} multiple={title.includes("to PDF")} />

      <Paper withBorder p="md" radius="md">
        <Stack gap="md">
          <Text fw={600}>Image Settings</Text>
          <Group grow>
            <Stack gap="xs">
              <Text size="sm" fw={500}>
                Image Format
              </Text>
              <SegmentedControl
                value={format}
                onChange={setFormat}
                data={[
                  { label: "JPG", value: "jpg" },
                  { label: "PNG", value: "png" },
                ]}
                radius="md"
              />
            </Stack>
            <Stack gap="xs">
              <Text size="sm" fw={500}>
                Resolution (DPI)
              </Text>
              <Select
                defaultValue="150"
                radius="md"
                data={[
                  { label: "72 DPI (Low)", value: "72" },
                  { label: "150 DPI (Medium)", value: "150" },
                  { label: "300 DPI (High)", value: "300" },
                  { label: "600 DPI (UHD)", value: "600" },
                ]}
              />
            </Stack>
          </Group>

          <Divider />

          <Stack gap="xs">
            <Group justify="space-between">
              <Text size="sm" fw={500}>
                Image Quality
              </Text>
              <Badge color="orange">High</Badge>
            </Group>
            <Slider
              defaultValue={85}
              marks={[
                { value: 0, label: "Small" },
                { value: 100, label: "Sharp" },
              ]}
              mb="xl"
            />
          </Stack>
        </Stack>
      </Paper>
    </Stack>
  );
}
