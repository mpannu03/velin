import { JSX } from "react";

export function ModifyScreen(): JSX.Element {
  return(
    <div
      style={{
        width: '100%',
        height: '100%',
        background: '#f0f0f0',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      Modify Screen
    </div>
  );
}