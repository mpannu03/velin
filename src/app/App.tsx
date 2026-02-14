import '@mantine/core/styles.css';
import '@mantine/notifications/styles.css';
import './styles.css'
import { JSX, useEffect, useState } from 'react';
import { Notifications } from '@mantine/notifications';
import { MantineProvider } from "@mantine/core";
import { ShellLayout } from "@/shell";
import { velinTheme } from './theme';
import { ScreenRouter } from './screenRouter';
import { useDocumentRepositoryStore, useSettingsStore } from './store';
import { DictionaryDownloadPrompt, isDictionaryInstalled } from '@/services/dictionary';

export function App(): JSX.Element {
  const settings = useSettingsStore((state) => state.settings);
  const [showDictionaryPrompt, setShowDictionaryPrompt] = useState(false);

  useEffect(() => {
    const initStorage = async () => {
      await useSettingsStore.getState().init();
      await useDocumentRepositoryStore.getState().init();
      
      const installed = await isDictionaryInstalled();
      if (!installed) {
        setShowDictionaryPrompt(true);
      }
    };
    initStorage();
  }, []);

  return(
    <MantineProvider
      theme={velinTheme(settings.appearance.color)}
      defaultColorScheme={settings.appearance.colorScheme}
    >
      <Notifications />
      <DictionaryDownloadPrompt 
        opened={showDictionaryPrompt} 
        onClose={() => setShowDictionaryPrompt(false)}
        onComplete={() => setShowDictionaryPrompt(false)}
      />
      <ShellLayout>
        <ScreenRouter />
      </ShellLayout>
    </MantineProvider>
  );
}