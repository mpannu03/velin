import { create } from 'zustand';

export type ViewerTool = 'cursor' | 'hand';
export type SidebarPanel = 'none' | 'comments' | 'bookmarks';

export type ViewerState = {
    scale: number;
    tool: ViewerTool;
    sidebar: SidebarPanel;
    scrollOffset: number;
};

type PdfViewerStore = {
    states: Record<string, ViewerState>;

    setScale: (id: string, scale: number) => void;
    setTool: (id: string, tool: ViewerTool) => void;
    setSidebar: (id: string, sidebar: SidebarPanel) => void;
    setScrollOffset: (id: string, offset: number) => void;
    getState: (id: string) => ViewerState;
};

const DEFAULT_STATE: ViewerState = {
    scale: 1.0,
    tool: 'cursor',
    sidebar: 'none',
    scrollOffset: 0,
};

export const usePdfViewerStore = create<PdfViewerStore>((set, get) => ({
    states: {},

    setScale: (id, scale) => set((state) => ({
        states: {
            ...state.states,
            [id]: {
                ...(state.states[id] || DEFAULT_STATE),
                scale,
            },
        },
    })),

    setTool: (id, tool) => set((state) => ({
        states: {
            ...state.states,
            [id]: {
                ...(state.states[id] || DEFAULT_STATE),
                tool,
            },
        },
    })),

    setSidebar: (id, sidebar) => set((state) => ({
        states: {
            ...state.states,
            [id]: {
                ...(state.states[id] || DEFAULT_STATE),
                sidebar,
            },
        },
    })),

    setScrollOffset: (id, offset) => set((state) => ({
        states: {
            ...state.states,
            [id]: {
                ...(state.states[id] || DEFAULT_STATE),
                scrollOffset: offset,
            },
        },
    })),

    getState: (id) => get().states[id] || DEFAULT_STATE,
}));
