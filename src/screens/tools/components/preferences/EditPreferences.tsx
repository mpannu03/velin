import {
  Paper,
  Stack,
  Text,
  TextInput,
  ColorInput,
  Slider,
  SegmentedControl,
  Divider,
  Select,
  NumberInput,
  Checkbox,
  Group,
} from "@mantine/core";
import { JSX, useState } from "react";
import { FileSelection } from "./FileSelection";

export function EditPreferences({ toolId }: { toolId: string }): JSX.Element {
  const [rotation, setRotation] = useState("90");
  const [watermarkText, setWatermarkText] = useState("Velin PDF");

  return (
    <Stack gap="lg">
      <FileSelection onSelect={() => {}} />

      <Paper withBorder p="md" radius="md">
        <Stack gap="md">
          {toolId === "rotate" && (
            <>
              <Text fw={600}>Rotation Settings</Text>
              <Stack gap="xs">
                <Text size="sm" fw={500}>
                  Rotate All Pages
                </Text>
                <SegmentedControl
                  fullWidth
                  value={rotation}
                  onChange={setRotation}
                  data={[
                    { label: "90° Clockwise", value: "90" },
                    { label: "180°", value: "180" },
                    { label: "90° Counter-Clockwise", value: "270" },
                  ]}
                  radius="md"
                />
              </Stack>

              <Divider label="Page Selection" labelPosition="center" />
              <Select
                label="Rotate Which Pages"
                defaultValue="all"
                data={[
                  { label: "All Pages", value: "all" },
                  { label: "Portrait Pages Only", value: "portrait" },
                  { label: "Landscape Pages Only", value: "landscape" },
                ]}
                radius="md"
              />
            </>
          )}

          {toolId === "watermark" && (
            <>
              <Text fw={600}>Watermark Settings</Text>
              <TextInput
                label="Watermark Text"
                placeholder="Enter text"
                value={watermarkText}
                onChange={(e) => setWatermarkText(e.currentTarget.value)}
                radius="md"
              />

              <Group grow>
                <ColorInput
                  label="Text Color"
                  defaultValue="#000000"
                  radius="md"
                />
                <NumberInput
                  label="Font Size"
                  defaultValue={48}
                  min={8}
                  radius="md"
                />
              </Group>

              <Divider />

              <Stack gap="xs">
                <Text size="sm" fw={500}>
                  Position & Opacity
                </Text>
                <Select
                  label="Placement"
                  placeholder="Select position"
                  defaultValue="center"
                  data={[
                    { label: "Top Left", value: "tl" },
                    { label: "Top Center", value: "tc" },
                    { label: "Top Right", value: "tr" },
                    { label: "Center", value: "center" },
                    { label: "Bottom Left", value: "bl" },
                    { label: "Bottom Center", value: "bc" },
                    { label: "Bottom Right", value: "br" },
                  ]}
                  radius="md"
                />
                <Stack gap={4} mt="xs">
                  <Group justify="space-between">
                    <Text size="xs">Opacity</Text>
                    <Text size="xs">30%</Text>
                  </Group>
                  <Slider defaultValue={30} label={(val) => `${val}%`} />
                </Stack>
              </Stack>
            </>
          )}

          {toolId === "extract" && (
            <>
              <Text fw={600}>Extraction Settings</Text>
              <TextInput
                label="Page Numbers"
                placeholder="e.g. 1, 3, 5-10"
                description="Use commas to separate individual pages or ranges."
                radius="md"
              />
              <Checkbox label="Extract pages as separate files" mt="sm" />
            </>
          )}
        </Stack>
      </Paper>
    </Stack>
  );
}
