import { create } from 'zustand';
import { PdfViewerState, createPdfViewerState } from '@/shared/types/pdf';

type ViewerStore = {
  viewers: Record<string, PdfViewerState>;

  ensureViewer: (documentId: string) => void;
  setZoom: (documentId: string, zoom: number) => void;
  setScrollTop: (documentId: string, scrollTop: number) => void;
  setPage: (documentId: string, page: number) => void;
};

export const useViewerStore = create<ViewerStore>((set, get) => ({
  viewers: {},

  ensureViewer(documentId) {
    if (get().viewers[documentId]) return;

    set(state => ({
      viewers: {
        ...state.viewers,
        [documentId]: createPdfViewerState(documentId),
      },
    }));
  },

  setZoom(documentId, zoom) {
    set(state => ({
      viewers: {
        ...state.viewers,
        [documentId]: {
          ...state.viewers[documentId],
          zoom,
        },
      },
    }));
  },

  setScrollTop(documentId, scrollTop) {
    set(state => ({
      viewers: {
        ...state.viewers,
        [documentId]: {
          ...state.viewers[documentId],
          scrollTop,
        },
      },
    }));
  },

  setPage(documentId, page) {
    set(state => ({
      viewers: {
        ...state.viewers,
        [documentId]: {
          ...state.viewers[documentId],
          page,
        },
      },
    }));
  },
}));
