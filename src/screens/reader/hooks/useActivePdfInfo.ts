import { useEffect } from 'react';
import { useReaderStore } from '../store';
import { fetchPdfInfo } from '@/shared/tauri/reader';
import { useDocumentsStore } from '@/app/store/documents.store';

export function useActivePdfInfo() {
  const activeDocumentId = useDocumentsStore(
    state => state.activeDocumentId
  );

  const { pdfInfo, loading, setPdfInfo, setLoading, clearLoading } =
    useReaderStore();

  useEffect(() => {
    if (!activeDocumentId) return;
    if (pdfInfo[activeDocumentId]) return;
    if (loading.has(activeDocumentId)) return;

    setLoading(activeDocumentId);

    fetchPdfInfo(activeDocumentId)
      .then(info => {
        setPdfInfo(activeDocumentId, info);
      })
      .finally(() => {
        clearLoading(activeDocumentId);
      });
  }, [
    activeDocumentId,
    pdfInfo,
    loading,
    setPdfInfo,
    setLoading,
    clearLoading,
  ]);
}
