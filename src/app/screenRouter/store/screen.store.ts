import { Screen } from "../../types";
import { create } from "zustand";

interface ScreenState {
  screen: Screen

  goHome(): void;
  openReader(): void;
  openModify(): void;
  openTools(): void;
}

export const useScreenState = create<ScreenState>((set) => ({
  screen: { name: 'home' },

  goHome: () => set({ screen: { name: 'home' } }),

  openReader: () => set({ screen: { name: 'reader' } }),

  openModify: () =>  set({ screen: { name: 'modify' } }),

  openTools: () => set({ screen: { name: 'tools' } }),
}));