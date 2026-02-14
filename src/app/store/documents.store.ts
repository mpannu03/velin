import { create } from 'zustand';
import { PdfDocument } from '@/shared/types/pdf';
import { openPdf, closePdf, fetchPdfInfo } from '@/services/tauri';
import { path } from '@tauri-apps/api';
import { InvokeResult } from '@/services/tauri';
import { documentRepository } from '@/services/storage';
import { useDocumentRepositoryStore } from '@/app/store';
import { savePreview } from '@/services/image/previewPng';

type DocumentsState = {
  documents: Record<string, PdfDocument>;
  activeDocumentId: string | null;
  documentOrder: string[];

  open: (filePath: string) => Promise<InvokeResult<string>>;
  close: (id: string) => Promise<InvokeResult<void>>;
  setActive: (id: string) => void;
  reorder: (activeId: string, overId: string) => void;
};

export const useDocumentsStore = create<DocumentsState>((set, get) => ({
  documents: {},
  activeDocumentId: null,
  documentOrder: [],

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
      documentOrder: [...state.documentOrder, id],
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
        currentPage: 0,
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

    set((state) => {
      const ids = state.documentOrder;
      const closingIndex = ids.indexOf(id);

      const { [id]: _, ...rest } = state.documents;

      let newActive = state.activeDocumentId;

      if (state.activeDocumentId === id) {
        if (ids.length > 1) {
          const prevIndex = closingIndex - 1;

          if (prevIndex >= 0) {
            newActive = ids[prevIndex];
          } else {
            newActive = ids[closingIndex + 1] ?? null;
          }
        } else {
          newActive = null;
        }
      }

    return {
      documents: rest,
      activeDocumentId: newActive,
      documentOrder: state.documentOrder.filter(docId => docId !== id),
    };
  });

  return { ok: true, data: undefined };
},

  setActive(id) {
    set({ activeDocumentId: id });
  },

  reorder(activeId, overId) {
    set((state) => {
      const oldIndex = state.documentOrder.indexOf(activeId);
      const newIndex = state.documentOrder.indexOf(overId);

      if (oldIndex === -1 || newIndex === -1) return state;

      const newOrder = [...state.documentOrder];
      newOrder.splice(oldIndex, 1);
      newOrder.splice(newIndex, 0, activeId);

      return { documentOrder: newOrder };
    });
  },
}));
