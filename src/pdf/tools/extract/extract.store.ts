import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import { extractPdf } from "@/services/tauri";
import { create } from "zustand";
import i18next from "@/services/i18n/i18n";

interface ExtractState {
  file: string;
  selection: string;
  destinationPath: string;
  isLoading: boolean;
  setFile: (file: string) => void;
  setSelection: (selection: string) => void;
  setDestinationPath: (path: string) => void;
  removeFile: () => void;
  setIsLoading: (loading: boolean) => void;
  runExtract: () => Promise<void>;
}

export const useExtractStore = create<ExtractState>((set, get) => ({
  file: "",
  selection: "",
  destinationPath: "",
  isLoading: false,

  setFile: (file: string) => set({ file }),

  setSelection: (selection: string) => set({ selection }),

  setDestinationPath: (path: string) => set({ destinationPath: path }),

  removeFile: () => set({ file: "", selection: "", destinationPath: "" }),

  setIsLoading: (loading: boolean) => set({ isLoading: loading }),

  runExtract: async () => {
    const {
      file,
      selection,
      destinationPath,
      isLoading,
      setIsLoading,
      removeFile,
    } = get();

    if (!file) {
      notifyWarning(i18next.t("tools:tools.extract.notifications.warning.no_file"));
      return;
    }

    if (!selection) {
      notifyWarning(i18next.t("tools:tools.extract.notifications.warning.no_selection"));
      return;
    }

    if (!isLoading) {
      setIsLoading(true);
      const input = { file, selection };
      const result = await extractPdf(input, destinationPath);

      if (result.ok) {
        notifySuccess(i18next.t("tools:tools.extract.notifications.success"));
        removeFile();
      } else {
        notifyError(
          result.error ??
            i18next.t("tools:tools.extract.notifications.error"),
        );
      }
      setIsLoading(false);
    }
  },
}));
