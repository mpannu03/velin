import { ReaderSettings, Settings } from "@/shared/types";
import { Box, NumberInput, Select, Stack, Text } from "@mantine/core";
import { JSX } from "react";
import { useTranslation } from "react-i18next";

export function ReaderSection({
  settings,
  updateReader,
}: {
  settings: Settings;
  updateReader: (settings: Partial<ReaderSettings>) => void;
}): JSX.Element {
  const { t } = useTranslation("settings");
  return (
    <Stack gap="xl">
      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">
          {t("reader.defaultViewMode.title")}
        </Text>
        <Select
          value={settings.reader.defaultViewMode}
          onChange={(value) => updateReader({ defaultViewMode: value as any })}
          data={[
            { label: t("reader.defaultViewMode.single"), value: "single" },
            {
              label: t("reader.defaultViewMode.continuous"),
              value: "continuous",
            },
            { label: t("reader.defaultViewMode.double"), value: "double" },
          ]}
          radius="md"
          allowDeselect={false}
        />
      </Box>

      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">
          {t("reader.defaultZoom")}
        </Text>
        <NumberInput
          value={settings.reader.defaultZoom}
          onChange={(value) =>
            updateReader({
              defaultZoom: typeof value === "number" ? value : 1.0,
            })
          }
          min={0.1}
          max={5.0}
          step={0.1}
          decimalScale={1}
          radius="md"
        />
      </Box>

      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">
          {t("reader.scrollSensitivity")}
        </Text>
        <NumberInput
          value={settings.reader.scrollSensitivity}
          onChange={(value) =>
            updateReader({
              scrollSensitivity: typeof value === "number" ? value : 1.0,
            })
          }
          min={0.1}
          max={3.0}
          step={0.1}
          decimalScale={1}
          radius="md"
        />
      </Box>
    </Stack>
  );
}
