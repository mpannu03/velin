import { JSX, ReactNode } from "react";
import { AppShell } from "@mantine/core";
import { ScreenNavigationBar } from "@/app/screenRouter";
import { TitleBar } from "./components";

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