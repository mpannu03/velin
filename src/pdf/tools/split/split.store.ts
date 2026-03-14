import { create } from "zustand";
import { SplitMode } from ".";
import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import { getPageCount, splitPdf } from "@/services/tauri";
import { generateEachPageSelection, generateFixedSizeSplit } from "./utils";

interface SplitState {
  file: string;
  selection: string;
  destinationDir: string;
  isLoading: boolean;
  splitMode: SplitMode;

  setFile: (file: string) => void;
  setSelection: (selection: string) => void;
  setDestinationDir: (dir: string) => void;
  removeFile: () => void;
  setIsLoading: (isLoading: boolean) => void;
  setSplitMode: (splitMode: SplitMode) => void;
  runSplit: () => Promise<void>;
}

export const useSplitStore = create<SplitState>((set, get) => ({
  file: "",
  selection: "",
  isLoading: false,
  splitMode: "ranges" as SplitMode,
  destinationDir: "",

  setFile: (file) => set({ file }),

  setSelection: (selection) => set({ selection }),

  setDestinationDir: (destinationDir) => set({ destinationDir }),

  removeFile: () => set({ file: "", selection: "", destinationDir: "" }),

  setIsLoading: (isLoading) => set({ isLoading }),

  setSplitMode: (splitMode) => set({ splitMode }),

  runSplit: async () => {
    const { file, selection, isLoading, setIsLoading, splitMode } = get();
    if (file && !isLoading) {
      setIsLoading(true);
      let result: Awaited<ReturnType<typeof splitPdf>>;
      const input = { file, selection };
      const currentDestDir =
        get().destinationDir ||
        file.substring(0, file.lastIndexOf(file.split(/[/\\]/).pop() || ""));
      const fileName = file.split(/[/\\]/).pop() || "";
      switch (splitMode) {
        case "ranges":
          if (!selection) {
            notifyWarning("Please select pages to split.");
            setIsLoading(false);
            return;
          }
          result = await splitPdf(input, currentDestDir, fileName);
          break;
        case "fixedSize":
          if (!selection) {
            notifyWarning("Please select pages to split.");
            setIsLoading(false);
            return;
          }
          const info = await getPageCount(input.file);
          if (!info.ok) {
            notifyError(info.error);
            setIsLoading(false);
            return;
          }
          const ranges = generateFixedSizeSplit(info.data, parseInt(selection));
          input.selection = ranges;
          result = await splitPdf(input, currentDestDir, fileName);
          break;
        case "allPages":
          const pageInfo = await getPageCount(input.file);
          if (!pageInfo.ok) {
            notifyError(pageInfo.error);
            setIsLoading(false);
            return;
          }
          input.selection = generateEachPageSelection(pageInfo.data);
          result = await splitPdf(input, currentDestDir, fileName);
          break;
      }
      if (result.ok) {
        notifySuccess("PDF file split successfully.");
      } else {
        notifyError(
          result.error ??
            "An unexpected error occurred while splitting the PDF.",
        );
      }
      setIsLoading(false);
    } else {
      notifyWarning("Please select a PDF file to split.");
    }
  },
}));
