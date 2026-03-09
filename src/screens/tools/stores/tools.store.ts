import { create } from "zustand";
import { ToolInfo } from "@/pdf/tools";

interface ToolsState {
  currentTool: ToolInfo | null;
  setCurrentTool: (tool: ToolInfo | null) => void;
}

export const useToolsStore = create<ToolsState>((set) => ({
  currentTool: null,
  setCurrentTool: (tool: ToolInfo | null) => set({ currentTool: tool }),
}));
