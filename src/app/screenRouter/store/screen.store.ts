import { Screen } from "app/types";
import { create } from "zustand";

interface ScreenState {
  screen: Screen

  goHome(): void;
  openReader(filePath: string): void;
  openModify(filePath: string): void;
  openTools(): void;
}

export const useScreenState = create<ScreenState>((set) => ({
  screen: { name: 'home' },
  tabs: [],
  activeTabIf: null,

  goHome: () => set({ screen: { name: 'home' } }),

  openReader: (filePath) =>
    set({ screen: { name: 'reader', filePath } }),

  openModify: (filePath) => 
    set({ screen: { name: 'modify', filePath } }),

  openTools: () => set({ screen: { name: 'tools' } }),
}));