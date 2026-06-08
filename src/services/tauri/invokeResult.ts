import { invoke } from "@tauri-apps/api/core";

export type InvokeResult<T> =
  | { ok: true; data: T }
  | { ok: false; error: string };

export async function safeInvoke<T>(
  cmd: string,
  args?: Record<string, unknown>
): Promise<InvokeResult<T>> {
  try {
    const data = await invoke<T>(cmd, args);
    return { ok: true, data };
  } catch (err) {
    return {
      ok: false,
      error:
        typeof err === "string"
          ? err
          : (err as any)?.message ?? "Unexpected error",
    };
  }
}
