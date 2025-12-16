import { create } from 'zustand';
import { PdfTab } from 'app/types';

interface AppState {
  tabs: PdfTab[];
  activeTabIf: string | null;
}

export const useAppStore = create<AppState>((set) => ({
  tabs: [],
  activeTabIf: null,
}));
