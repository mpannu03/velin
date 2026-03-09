import {
  Badge,
  Group,
  Paper,
  Stack,
  Text,
  Slider,
  SegmentedControl,
  Divider,
  Alert,
} from "@mantine/core";
import { JSX, useState } from "react";
import { FiInfo } from "react-icons/fi";
import { FileSelection } from "../components";
import { ToolPreferencesProps } from "../types";

export function Compress({ setAction }: ToolPreferencesProps): JSX.Element {
  const [level, setLevel] = useState("recommended");
  console.log(setAction);

  const LEVELS = [
    {
      label: "Extreme",
      value: "extreme",
      description: "Highest compression, lowest quality",
    },
    {
      label: "Recommended",
      value: "recommended",
      description: "Good compression, high quality",
    },
    {
      label: "Less",
      value: "less",
      description: "Low compression, best quality",
    },
  ];

  return (
    <Stack gap="lg">
      <FileSelection onSelect={() => {}} />

      <Paper withBorder p="md" radius="md">
        <Stack gap="md">
          <Text fw={600}>Compression Level</Text>
          <SegmentedControl
            fullWidth
            value={level}
            onChange={setLevel}
            data={LEVELS.map((l) => ({ label: l.label, value: l.value }))}
            radius="md"
            size="md"
          />

          <Alert
            icon={<FiInfo size={16} />}
            title="About this level"
            color="blue"
            variant="light"
          >
            {LEVELS.find((l) => l.value === level)?.description}
          </Alert>

          <Divider />

          <Stack gap="xs">
            <Group justify="space-between">
              <Text size="sm" fw={500}>
                Quality vs. Size
              </Text>
              <Badge color="blue">Balance</Badge>
            </Group>
            <Slider
              defaultValue={70}
              marks={[
                { value: 0, label: "Size" },
                { value: 100, label: "Quality" },
              ]}
              mb="xl"
            />
          </Stack>
        </Stack>
      </Paper>
    </Stack>
  );
}
