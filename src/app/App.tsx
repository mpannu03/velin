import '@mantine/core/styles.css';
import { MantineProvider } from "@mantine/core";
import { ShellLayout } from "../shell/ShellLayout";
import { velinTheme } from './theme/theme';

export function App() {
  return(
    <MantineProvider
      theme={velinTheme}
      defaultColorScheme='light'
    >
      <ShellLayout>
      </ShellLayout>
    </MantineProvider>
  );
}