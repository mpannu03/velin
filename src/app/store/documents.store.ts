import { create } from 'zustand';
import { PdfDocument } from '@/shared/types/pdf';
import { openPdf, closePdf } from '@/shared/tauri/reader';
import { path } from '@tauri-apps/api';

type DocumentsState = {
  documents: Record<string, PdfDocument>;
  activeDocumentId: string | null;

  open: (filePath: string) => Promise<void>;
  close: (id: string) => Promise<void>;
  setActive: (id: string) => void;
};

export const useDocumentsStore = create<DocumentsState>((set) => ({
  documents: {},
  activeDocumentId: null,

  async open(filePath) {
    const id = await openPdf(filePath);
    const title = await path.basename(filePath);

    // const title = filePath.split(/[\\/]/).pop() ?? 'Untitled';

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
