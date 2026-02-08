import { create } from 'zustand';

export enum ViewerTool {
  Cursor = 'cursor',
  Hand = 'hand',
}

export enum SidebarPanel {
  None = 'none',
  Comments = 'comments',
  Bookmarks = 'bookmarks',
  Search = 'search',
}

export type ViewerState = {
  scale: number;
  tool: ViewerTool;
  sidebar: SidebarPanel;

  currentPage: number; // Zero based
  gotoPage: number | null;
};

type PdfViewerStore = {
  states: Record<string, ViewerState>;

  zoomIn: (id: string) => void;
  zoomOut: (id: string) => void;
  resetZoom: (id: string) => void;

  setTool: (id: string, tool: ViewerTool) => void;
  setSidebar: (id: string, sidebar: SidebarPanel) => void;

  setCurrentPage: (id: string, page: number) => void;
  gotoPage: (id: string, page: number) => void;
  clearGotoPage: (id: string) => void;

  getState: (id: string) => ViewerState;
  removeState: (id: string) => void;
};

const DEFAULT_STATE: ViewerState = {
  scale: 1.0,
  tool: ViewerTool.Cursor,
  sidebar: SidebarPanel.None,
  currentPage: 0,
  gotoPage: null,
};

export const usePdfViewerStore = create<PdfViewerStore>((set, get) => ({
  states: {},

  getState: (id) => {
    const existing = get().states[id];
    if (existing) return existing;

    const state = { ...DEFAULT_STATE };
    set(s => ({
      states: { ...s.states, [id]: state },
    }));
    return state;
  },

  removeState: (id) => set(state => {
    const next = { ...state.states };
    delete next[id];
    return { states: next };
  }),

  zoomIn: (id) => set(s => {
    const state = s.states[id] ?? DEFAULT_STATE;
    return {
      states: {
        ...s.states,
        [id]: { ...state, scale: nextZoom(state.scale) },
      },
    };
  }),

  zoomOut: (id) => set(s => {
    const state = s.states[id] ?? DEFAULT_STATE;
    return {
      states: {
        ...s.states,
        [id]: { ...state, scale: prevZoom(state.scale) },
      },
    };
  }),

  resetZoom: (id) => set(s => ({
    states: {
      ...s.states,
      [id]: { ...(s.states[id] ?? DEFAULT_STATE), scale: 1 },
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

  setCurrentPage: (id, page) => set(s => {
    const prev = s.getState(id);
    if (prev.currentPage === page) return s;
    return {
      states: {
        ...s.states,
        [id]: { ...(s.states[id] ?? DEFAULT_STATE), currentPage: page },
      },
    };
  }),

  gotoPage: (id, page) => set(s => ({
    states: {
      ...s.states,
      [id]: { ...(s.states[id] ?? DEFAULT_STATE), gotoPage: page },
    },
  })),

  clearGotoPage: (id) => set(s => ({
    states: {
      ...s.states,
      [id]: { ...(s.states[id] ?? DEFAULT_STATE), gotoPage: null },
    },
  })),
}));

const ZOOM_STEPS = [0.1, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0, 5.0];

function nextZoom(scale: number) {
  return ZOOM_STEPS.find(s => s > scale) 
    ?? ZOOM_STEPS[ZOOM_STEPS.length - 1];
}

function prevZoom(scale: number) {
  return [...ZOOM_STEPS].reverse().find(s => s < scale) 
    ?? ZOOM_STEPS[0];
}
