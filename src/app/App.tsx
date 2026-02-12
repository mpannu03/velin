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
import { useSettingsStore } from './store/settings.store';

export function App(): JSX.Element {
  const settings = useSettingsStore((state) => state.settings);

  useEffect(() => {
    const initStorage = async () => {
      await useSettingsStore.getState().init();
      await useDocumentRepositoryStore.getState().init();
    };
    initStorage();
  }, []);

  return(
    <MantineProvider
      theme={{
        ...velinTheme,
        primaryColor: settings.appearance.accentColor || 'blue',
      }}
      forceColorScheme={settings.appearance.theme === 'system' ? undefined : settings.appearance.theme}
      defaultColorScheme='light'
    >
      <Notifications />
      <ShellLayout>
        <ScreenRouter />
      </ShellLayout>
    </MantineProvider>
  );
}