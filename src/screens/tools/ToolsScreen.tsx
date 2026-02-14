import { JSX } from "react";

export function ToolsScreen(): JSX.Element {
  return(
    <div
      style={{
        width: '100%',
        height: '100%',
        background: 'light-dark(var(--mantine-color-gray-1), var(--mantine-color-dark-6))',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      Tools Screen
    </div>
  );
}