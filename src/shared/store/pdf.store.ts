import { create } from 'zustand';
import { createPdfDocument, PdfDocument } from '@/shared/types';
import { path } from '@tauri-apps/api';

interface PdfState {
  tabs: PdfDocument[];
  activeTab: string | null;

  openPdf(filePath: string): void;
  closePdf(filePath: string): void;
  setActivePdf(filePath: string): void;
}

export const usePdfTabs = create<PdfState>((set, get) => ({
  tabs: [],
  activeTab: null,

  openPdf: async (filePath: string) => {
    const existingtab = get().tabs.find(
      (t) => t.filePath == filePath
    );

    if (existingtab) {
      set({ activeTab: filePath });
      return;
    }
    
    const title = await path.basename(filePath);
    const pdf: PdfDocument = createPdfDocument({
      filePath,
      title,
    })

    set((state) => ({
      tabs: [...state.tabs, pdf],
      activeTab: pdf.filePath,
    }));
  },

  closePdf: (filePath: string) => {
    set((state) => {
      const tabs = state.tabs.filter((t) => t.filePath !== filePath);

      let activeTab = state.activeTab;
      if (state.activeTab === filePath) {
        const lastTab = tabs.length > 0 ? tabs[tabs.length - 1] : undefined;
        activeTab = lastTab ? lastTab.filePath : null;
      }

      return { tabs, activeTab };
    });
  },

  setActivePdf: (filePath: string) => {
    set({ activeTab: filePath });
  },
}));