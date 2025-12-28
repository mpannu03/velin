import { invoke } from "@tauri-apps/api/core"
import { RenderedPage } from "../types"

export function usePdfPage(
  id: string,
  pageIndex: number,
  targetWidth: number
) {
  const load = async (): Promise<RenderedPage> => {
    return await invoke<RenderedPage>("render_page", {
      id,
      pageIndex,
      targetWidth,
    })
  }

  return { load }
}
