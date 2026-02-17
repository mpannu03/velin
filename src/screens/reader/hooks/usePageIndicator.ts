import { useDocumentCacheStore, usePdfViewerStore } from "../stores";

export function usePageIndicator(id: string) {
  const currentPage = usePdfViewerStore(
    (s) => s.getState(id).currentPage
  );

  const pageCount = useDocumentCacheStore(
    (s) => s.getInfo(id)?.page_count
  );

  if (pageCount == null) {
    return null;
  }

  return {
    current: currentPage + 1, // user-facing
    total: pageCount,
  };
}
