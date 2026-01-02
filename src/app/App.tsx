import '@mantine/core/styles.css';
import '@mantine/notifications/styles.css';
import './styles.css'
import { MantineProvider } from "@mantine/core";
import { ShellLayout } from "@/shell/ShellLayout";
import { velinTheme } from './theme/theme';
import { ScreenRouter } from './screenRouter/ScreenRouter';
import { JSX } from 'react';
import { Notifications } from '@mantine/notifications';

export function App(): JSX.Element {
  return(
    <MantineProvider
      theme={velinTheme}
      defaultColorScheme='light'
    >
      <Notifications />
      <ShellLayout>
        <ScreenRouter />
      </ShellLayout>
    </MantineProvider>
  );
}