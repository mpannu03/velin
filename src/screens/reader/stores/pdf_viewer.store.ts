import { create } from 'zustand';

export type ViewerTool = 'cursor' | 'hand';
export type SidebarPanel = 'none' | 'comments' | 'bookmarks';

export type ViewerState = {
  scale: number;
  tool: ViewerTool;
  sidebar: SidebarPanel;
  // scrollOffset: number;

  gotoPage: number | null;
};

type PdfViewerStore = {
  states: Record<string, ViewerState>;

  zoomIn: (id: string) => void;
  zoomOut: (id: string) => void;
  resetZoom: (id: string) => void;

  setTool: (id: string, tool: ViewerTool) => void;
  setSidebar: (id: string, sidebar: SidebarPanel) => void;

  gotoPage: (id: string, page: number) => void;
  clearGotoPage: (id: string) => void;

  getState: (id: string) => ViewerState;
  removeState: (id: string) => void;
};

const DEFAULT_STATE: ViewerState = {
  scale: 1.0,
  tool: 'cursor',
  sidebar: 'none',
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

  // setScrollOffset: (id, offset) => set((state) => ({
  //   states: {
  //     ...state.states,
  //     [id]: {
  //       ...(state.states[id] || DEFAULT_STATE),
  //       scrollOffset: offset,
  //     },
  //   },
  // })),

  // getState: (id) => get().states[id] || DEFAULT_STATE,
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
