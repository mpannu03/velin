import '@mantine/core/styles.css';
import { MantineProvider } from "@mantine/core";
import { ShellLayout } from "@/shell/ShellLayout";
import { velinTheme } from './theme/theme';
import { ScreenRouter } from './screenRouter/ScreenRouter';
import { JSX } from 'react';

export function App(): JSX.Element {
  return(
    <MantineProvider
      theme={velinTheme}
      defaultColorScheme='light'
    >
      <ShellLayout>
        <ScreenRouter />
      </ShellLayout>
    </MantineProvider>
  );
}