import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import { rotatePdf } from "@/services/tauri";
import { create } from "zustand";
import i18next from "@/services/i18n/i18n";

interface RotateState {
  file: string;
  selection: string;
  pagesMode: "all" | "select";
  destinationPath: string;
  angle: number;
  isLoading: boolean;
  setFile: (file: string) => void;
  setSelection: (selection: string) => void;
  setPagesMode: (mode: "all" | "select") => void;
  setDestinationPath: (path: string) => void;
  setAngle: (angle: number) => void;
  removeFile: () => void;
  setIsLoading: (loading: boolean) => void;
  runRotate: () => Promise<void>;
}

export const useRotateStore = create<RotateState>((set, get) => ({
  file: "",
  selection: "",
  pagesMode: "all",
  destinationPath: "",
  angle: 90,
  isLoading: false,

  setFile: (file: string) => set({ file }),

  setSelection: (selection: string) => set({ selection }),

  setPagesMode: (pagesMode) => set({ pagesMode }),

  setDestinationPath: (path: string) => set({ destinationPath: path }),

  setAngle: (angle: number) => set({ angle }),

  removeFile: () =>
    set({
      file: "",
      selection: "",
      pagesMode: "all",
      destinationPath: "",
      angle: 90,
    }),

  setIsLoading: (loading: boolean) => set({ isLoading: loading }),

  runRotate: async () => {
    const {
      file,
      selection,
      pagesMode,
      destinationPath,
      angle,
      isLoading,
      setIsLoading,
      removeFile,
    } = get();

    if (!file) {
      notifyWarning(
        i18next.t("tools:tools.rotate.notifications.warning.no_file"),
      );
      return;
    }

    if (pagesMode === "select" && !selection) {
      notifyWarning(
        i18next.t("tools:tools.rotate.notifications.warning.no_selection"),
      );
      return;
    }

    if (!isLoading) {
      setIsLoading(true);
      const input = {
        file,
        selection: pagesMode === "all" ? null : selection,
      };
      const result = await rotatePdf(input, destinationPath, angle);

      if (result.ok) {
        notifySuccess(i18next.t("tools:tools.rotate.notifications.success"));
        removeFile();
      } else {
        notifyError(
          result.error ?? i18next.t("tools:tools.rotate.notifications.error"),
        );
      }
      setIsLoading(false);
    }
  },
}));
