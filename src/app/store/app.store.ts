import { create } from 'zustand';
import { Screen } from '../screen';

interface AppState {
  screen: Screen;

  goHome(): void;
  openEditor(filePath: string): void;
  openTools(): void;
}

export const useAppStore = create<AppState>((set) => ({
  screen: { name: 'home' },

  goHome: () => set({ screen: { name: 'home' } }),

  openEditor: (filePath) =>
    set({ screen: { name: 'editor', filePath } }),

  openTools: () => set({ screen: { name: 'tools' } }),
}));
