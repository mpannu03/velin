import { JSX, ReactNode } from "react";
import { TitleBar } from "./components/TitleBar";
import { AppShell } from "@mantine/core";
import { ScreenNavigationBar } from "@/app/screenRouter/ScreenRouter";

export function ShellLayout(
  { children }: { children?: ReactNode }
): JSX.Element {
  return (
    <AppShell
      header={{ height: 92 }}
      styles={{
        main: {
          height: '100vh',
          display: 'flex',
          flexDirection: 'column',
        },
      }}
    >
      <AppShell.Header>
        <TitleBar />
        <ScreenNavigationBar />
      </AppShell.Header>
      <AppShell.Main>
        {children || null}
      </AppShell.Main>
    </AppShell>
  );
}