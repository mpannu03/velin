import { AppearanceSettings, Settings } from "@/shared/types";
import { Box, Stack, Text, SegmentedControl, ActionIcon, ColorSwatch, Divider, Group, MantineColorScheme, useMantineTheme, useMantineColorScheme } from "@mantine/core";
import { JSX } from "react";
import { FiCheck, FiMonitor, FiMoon, FiSun } from "react-icons/fi";
import { THEME_COLORS } from "@/app/theme";

export function AppearanceSection({
  settings,
  updateAppearance,
}: {
  settings: Settings;
  updateAppearance: (settings: Partial<AppearanceSettings>) => void;
}): JSX.Element {
  const theme = useMantineTheme();
  const { setColorScheme } = useMantineColorScheme();
  
  return (
    <Stack gap="xl">
      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">
          Color Scheme
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
          Accent Color
        </Text>
        <Group gap="sm">
          {THEME_COLORS.map((color) => (
            <ActionIcon
              key={color}
              onClick={() => updateAppearance({ color })}
              variant={
                settings.appearance.color === color ? "filled" : "light"
              }
              color={color}
              size="xl"
              radius="xl"
            >
              {settings.appearance.color === color ? (
                <FiCheck size={18} />
              ) : (
                <ColorSwatch
                  color={theme.colors[color][6]}
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
              <FiSun size={14} /> Light
            </Group>
          ),
          value: "light",
        },
        {
          label: (
            <Group gap="xs" justify="center">
              <FiMoon size={14} /> Dark
            </Group>
          ),
          value: "dark",
        },
        {
          label: (
            <Group gap="xs" justify="center">
              <FiMonitor size={14} /> System
            </Group>
          ),
          value: "auto",
        },
      ]}
    />
  );
}