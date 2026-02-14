import { create } from 'zustand';
import type { PdfInfo } from '@/shared/types';

type ReaderState = {
  pdfInfo: Record<string, PdfInfo>;
  loading: Set<string>;

  setPdfInfo: (id: string, info: PdfInfo) => void;
  setLoading: (id: string) => void;
  clearLoading: (id: string) => void;
};

export const useReaderStore = create<ReaderState>((set) => ({
  pdfInfo: {},
  loading: new Set(),

  setPdfInfo(id, info) {
    set(state => ({
      pdfInfo: {
        ...state.pdfInfo,
        [id]: info,
      },
    }));
  },

  setLoading(id) {
    set(state => {
      const next = new Set(state.loading);
      next.add(id);
      return { loading: next };
    });
  },

  clearLoading(id) {
    set(state => {
      const next = new Set(state.loading);
      next.delete(id);
      return { loading: next };
    });
  },
}));
