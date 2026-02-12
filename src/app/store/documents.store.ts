import { create } from 'zustand';
import { PdfDocument } from '@/shared/types/pdf';
import { openPdf, closePdf, fetchPdfInfo } from '@/shared/tauri/reader';
import { path } from '@tauri-apps/api';
import { InvokeResult } from '@/shared/tauri';
import { documentRepository } from '@/shared/storage';
import { useDocumentRepositoryStore } from './repository.store';
import { savePreview } from '@/shared/services/previewPng';

type DocumentsState = {
  documents: Record<string, PdfDocument>;
  activeDocumentId: string | null;

  open: (filePath: string) => Promise<InvokeResult<string>>;
  close: (id: string) => Promise<InvokeResult<void>>;
  setActive: (id: string) => void;
};

export const useDocumentsStore = create<DocumentsState>((set, get) => ({
  documents: {},
  activeDocumentId: null,

  async open(filePath): Promise<InvokeResult<string>> {
    const result = await openPdf(filePath);

    if (!result.ok) {
      return result;
    }

    const title = await path.basename(filePath, '.pdf');
    const id = result.data;

    set(state => ({
      documents: {
        ...state.documents,
        [id]: {
          id,
          filePath,
          title,
        },
      },
      activeDocumentId: id,
    }));
    
    const existing = documentRepository.getByFilePath(filePath);
    if (existing) {
      await useDocumentRepositoryStore.getState().updateDocument(
        filePath,
        {
          openedCount: existing.openedCount + 1,
          lastOpened: Date.now(),
        }
      );

      return { ok: true, data: id };
    }

    let previewPath: string | undefined;
    let pagesCount = 0;

    const pdfInfo = await fetchPdfInfo(id);
    if (pdfInfo.ok) {
      pagesCount = pdfInfo.data.page_count;
    }

    try {
      previewPath = await savePreview(get().documents[id]);
    } catch {
      previewPath = undefined;
    }

    await useDocumentRepositoryStore.getState().addDocument(
      {
        filePath,
        title,
        previewPath,
        starred: false,
        lastOpened: Date.now(),
        currentPage: 1,
        pagesCount,
        openedCount: 1,
      }
    );

    return { ok: true, data: id }
  },

  async close(id: string): Promise<InvokeResult<void>> {
    const result = await closePdf(id);

    if (!result.ok) {
      return result;
    }

    set(state => {
      const { [id]: _, ...rest } = state.documents;
      return {
        documents: rest,
        activeDocumentId:
          state.activeDocumentId === id ? null : state.activeDocumentId,
      };
    });

    return { ok: true, data: undefined }
  },

  setActive(id) {
    set({ activeDocumentId: id });
  },
}));
