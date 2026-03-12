import { GeneralSettings, Settings } from "@/shared/types";
import { Box, Group, Select, Stack, Text, Switch } from "@mantine/core";
import { JSX } from "react";
import { Globe } from "lucide-react";
import { DictionarySettingsItem } from "./DictionarySettingsItem";
import { LANGUAGES } from "@/services/i18n";
import { useTranslation } from "react-i18next";

export function GeneralSection({
  settings,
  updateGeneral,
}: {
  settings: Settings;
  updateGeneral: (settings: Partial<GeneralSettings>) => void;
}): JSX.Element {
  const { t } = useTranslation("settings");
  return (
    <Stack gap="xl">
      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">
          {t("general.language")}
        </Text>
        <Select
          value={settings.general.language}
          onChange={(value) => updateGeneral({ language: value || "en" })}
          data={Object.entries(LANGUAGES).map(([value, label]) => ({
            value,
            label,
          }))}
          leftSection={<Globe size={16} />}
          radius="md"
          allowDeselect={false}
        />
      </Box>

      <Group justify="space-between" align="flex-start" wrap="nowrap">
        <Box>
          <Text fw={500}>{t("general.updates.title")}</Text>
          <Text size="xs" c="dimmed">
            {t("general.updates.description")}
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
