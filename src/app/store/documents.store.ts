import { create } from 'zustand';
import { PdfDocument } from '@/shared/types/pdf';
import { openPdf, closePdf } from '@/shared/tauri/reader';

type DocumentsState = {
  documents: Record<string, PdfDocument>;
  activeDocumentId: string | null;

  open: (path: string) => Promise<void>;
  close: (id: string) => Promise<void>;
  setActive: (id: string) => void;
};

export const useDocumentsStore = create<DocumentsState>((set) => ({
  documents: {},
  activeDocumentId: null,

  async open(path) {
    const id = await openPdf(path);

    const title = path.split(/[\\/]/).pop() ?? 'Untitled';

    set(state => ({
      documents: {
        ...state.documents,
        [id]: {
          id,
          filePath: path,
          title,
        },
      },
      activeDocumentId: id,
    }));
  },

  async close(id) {
    await closePdf(id);

    set(state => {
      const { [id]: _, ...rest } = state.documents;
      return {
        documents: rest,
        activeDocumentId:
          state.activeDocumentId === id ? null : state.activeDocumentId,
      };
    });
  },

  setActive(id) {
    set({ activeDocumentId: id });
  },
}));
