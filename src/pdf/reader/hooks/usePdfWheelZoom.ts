import { usePdfViewerStore } from "../stores";
import { useEventListener } from "@mantine/hooks";

export function usePdfWheelZoom(documentId: string) {
  const zoomIn = usePdfViewerStore(s => s.zoomIn);
  const zoomOut = usePdfViewerStore(s => s.zoomOut);

  const ref = useEventListener(
    'wheel',
    (event: WheelEvent) => {
      if (!event.ctrlKey && !event.metaKey) return;

      event.preventDefault();
      event.deltaY < 0 ? zoomIn(documentId) : zoomOut(documentId);
    },
  );

  return ref;
}