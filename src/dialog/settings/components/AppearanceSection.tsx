import { AppearanceSettings, Settings } from "@/shared/types";
import {
  Box,
  Stack,
  Text,
  SegmentedControl,
  ActionIcon,
  ColorSwatch,
  Divider,
  Group,
  MantineColorScheme,
  useMantineTheme,
  useMantineColorScheme,
} from "@mantine/core";
import { JSX } from "react";
import { Check, Monitor, Moon, Sun } from "lucide-react";
import { THEME_COLORS } from "@/app/theme";
import { useTranslation } from "react-i18next";

export function AppearanceSection({
  settings,
  updateAppearance,
}: {
  settings: Settings;
  updateAppearance: (settings: Partial<AppearanceSettings>) => void;
}): JSX.Element {
  const { t } = useTranslation("settings");
  const theme = useMantineTheme();
  const { setColorScheme } = useMantineColorScheme();

  return (
    <Stack gap="xl">
      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">
          {t("appearance.colorScheme.title")}
        </Text>
        <SegmentedControlCustom
          value={settings.appearance.colorScheme}
          onChange={(val) => {
            updateAppearance({ colorScheme: val as MantineColorScheme });
            setColorScheme(val as MantineColorScheme);
          }}
        />
      </Box>

      <Divider />

      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">
          {t("appearance.accentColor")}
        </Text>
        <Group gap="sm">
          {THEME_COLORS.map((color) => (
            <ActionIcon
              key={color}
              onClick={() => updateAppearance({ color })}
              variant={settings.appearance.color === color ? "filled" : "light"}
              color={color}
              size="xl"
              radius="xl"
            >
              {settings.appearance.color === color ? (
                <Check size={18} />
              ) : (
                <ColorSwatch
                  color={theme.colors[color as keyof typeof theme.colors][6]}
                  size={24}
                />
              )}
            </ActionIcon>
          ))}
        </Group>
      </Box>
    </Stack>
  );
}

function SegmentedControlCustom({
  value,
  onChange,
}: {
  value: string;
  onChange: (val: string) => void;
}) {
  const { t } = useTranslation("settings");
  return (
    <SegmentedControl
      value={value}
      onChange={onChange}
      fullWidth
      radius="md"
      data={[
        {
          label: (
            <Group gap="xs" justify="center">
              <Sun size={14} /> {t("appearance.colorScheme.light")}
            </Group>
          ),
          value: "light",
        },
        {
          label: (
            <Group gap="xs" justify="center">
              <Moon size={14} /> {t("appearance.colorScheme.dark")}
            </Group>
          ),
          value: "dark",
        },
        {
          label: (
            <Group gap="xs" justify="center">
              <Monitor size={14} /> {t("appearance.colorScheme.system")}
            </Group>
          ),
          value: "auto",
        },
      ]}
    />
  );
}
