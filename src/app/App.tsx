import '@mantine/core/styles.css';
import '@mantine/notifications/styles.css';
import './styles.css'
import { MantineProvider } from "@mantine/core";
import { ShellLayout } from "@/shell/ShellLayout";
import { velinTheme } from './theme/theme';
import { ScreenRouter } from './screenRouter/ScreenRouter';
import { JSX, useEffect } from 'react';
import { Notifications } from '@mantine/notifications';
import { useDocumentRepositoryStore } from './store/repository.store';

export function App(): JSX.Element {
  useEffect(() => {
    const initStorage = async () => {
      await useDocumentRepositoryStore.getState().init();
    };
    initStorage();
  }, []);

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