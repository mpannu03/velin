import { create } from 'zustand';
import { PdfDocument } from '@/shared/types/pdf';
import { openPdf, closePdf } from '@/shared/tauri/reader';
import { path } from '@tauri-apps/api';
import { InvokeResult } from '@/shared/tauri';

type DocumentsState = {
  documents: Record<string, PdfDocument>;
  activeDocumentId: string | null;

  open: (filePath: string) => Promise<InvokeResult<void>>;
  close: (id: string) => Promise<InvokeResult<void>>;
  setActive: (id: string) => void;
};

export const useDocumentsStore = create<DocumentsState>((set) => ({
  documents: {},
  activeDocumentId: null,

  async open(filePath): Promise<InvokeResult<void>> {
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

    return { ok: true, data: undefined }
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
