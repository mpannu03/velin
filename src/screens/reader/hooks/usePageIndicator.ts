import { usePdfInfoStore, usePdfViewerStore } from "../stores";

export function usePageIndicator(id: string) {
  const currentPage = usePdfViewerStore(
    (s) => s.getState(id).currentPage
  );

  const pageCount = usePdfInfoStore(
    (s) => s.infoCache[id]?.page_count
  );

  if (pageCount == null) {
    return null;
  }

  return {
    current: currentPage + 1, // user-facing
    total: pageCount,
  };
}
