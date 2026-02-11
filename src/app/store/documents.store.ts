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

    let previewPath: string | undefined;
    try {
      previewPath = await savePreview(get().documents[id]);
      console.log("try" + previewPath);
    } catch(e) {
      previewPath = undefined;
      console.log("catch: " + e);
    }
    const pdfInfo = await fetchPdfInfo(id);
    const existing = documentRepository.getByFilePath(filePath);

    await useDocumentRepositoryStore.getState().updateDocument({
      ...existing,
      filePath,
      title,
      lastOpened: new Date().getTime(),
      starred: existing?.starred ?? false,
      currentPage: existing?.currentPage ?? 1,
      previewPath,
      pagesCount: pdfInfo.ok ? pdfInfo.data.page_count : 0,
      openedCount: existing ? existing.openedCount + 1 : 1,
    });

    console.log(useDocumentRepositoryStore.getState().documents);

    return { ok: true, data: id }
  },

  async close(id): Promise<InvokeResult<void>> {
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
