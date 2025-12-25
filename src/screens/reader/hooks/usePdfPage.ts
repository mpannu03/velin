import { invoke } from "@tauri-apps/api/core"
import { RenderedPage } from "../types"

export function usePdfPage(
  id: string,
  pageIndex: number,
  scale: number
) {
  const load = async (): Promise<RenderedPage> => {
    return await invoke<RenderedPage>("render_page", {
      id,
      pageIndex,
      scale
    })
  }

  return { load }
}
