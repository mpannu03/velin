import { GeneralSettings, Settings } from "@/shared/types";
import { Box, Group, Select, Stack, Text, Switch } from "@mantine/core";
import { JSX } from "react";
import { FiGlobe } from "react-icons/fi";
import { DictionarySettingsItem } from "./DictionarySettingsItem";

export function GeneralSection({
  settings,
  updateGeneral,
}: {
  settings: Settings;
  updateGeneral: (settings: Partial<GeneralSettings>) => void;
}): JSX.Element {
  return (
    <Stack gap="xl">
      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">
          Language
        </Text>
        <Select
          value={settings.general.language}
          onChange={(value) => updateGeneral({ language: value || "en" })}
          data={[
            { label: "English", value: "en" },
            { label: "Spanish", value: "es" },
            { label: "French", value: "fr" },
            { label: "German", value: "de" },
          ]}
          leftSection={<FiGlobe size={16} />}
          radius="md"
          allowDeselect={false}
        />
      </Box>

      <Group justify="space-between" align="flex-start" wrap="nowrap">
        <Box>
          <Text fw={500}>Check for updates on start</Text>
          <Text size="xs" c="dimmed">
            The app will automatically check for new versions on launch.
          </Text>
        </Box>
        <Switch
          checked={settings.general.checkUpdateOnStart}
          onChange={(event) =>
            updateGeneral({ checkUpdateOnStart: event.currentTarget.checked })
          }
          size="md"
        />
      </Group>

      <DictionarySettingsItem />
    </Stack>
  );
}