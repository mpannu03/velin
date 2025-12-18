import { JSX, ReactNode } from "react";
import { TitleBar } from "./components/TitleBar";
import { AppShell } from "@mantine/core";

export function ShellLayout(
  { children }: { children?: ReactNode }
): JSX.Element {
  return (
    <AppShell
    header={{ height: 36 }}
    >
      <AppShell.Header>
        <TitleBar />
      </AppShell.Header>
      <AppShell.Main>
        {children || null}
      </AppShell.Main>
    </AppShell>
  );
}