import { create } from 'zustand';
import { Screen } from '../';

interface AppState {
  screen: Screen;

  goHome(): void;
  openReader(filePath: string): void;
  openModify(filePath: string): void;
  openTools(): void;
}

export const useAppStore = create<AppState>((set) => ({
  screen: { name: 'home' },

  goHome: () => set({ screen: { name: 'home' } }),

  openReader: (filePath) =>
    set({ screen: { name: 'reader', filePath } }),

  openModify: (filePath) => 
    set({ screen: { name: 'modify', filePath } }),

  openTools: () => set({ screen: { name: 'tools' } }),
}));
