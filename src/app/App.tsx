import '@mantine/core/styles.css';
import { MantineProvider } from "@mantine/core";
import { ShellLayout } from "../shell/ShellLayout";
import { velinTheme } from './theme/theme';
import { ScreenRouter } from './ScreenRouter';
import { ReactNode } from 'react';

export function App(): ReactNode {
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