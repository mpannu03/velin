import { createTheme, MantineThemeOverride } from '@mantine/core';

export const THEME_COLORS = [
  'red',
  'pink',
  'grape',
  'violet',
  'indigo',
  'blue',
  'cyan',
  'teal',
  'green',
  'lime',
  'yellow',
  'orange',
]

export function velinTheme(
  colorKey: string
): MantineThemeOverride {
  return createTheme({
    primaryColor: colorKey,
    defaultRadius: 'md',
    focusRing: 'auto',
  });
}
