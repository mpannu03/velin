import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import i18next from "@/services/i18n/i18n";
import { create } from "zustand";
import { unlockPdf } from "@/services/tauri";

interface UnlockState {
  file: string;
  destinationPath: string;
  password: string;
  isLoading: boolean;
  setFile: (file: string) => void;
  setDestinationPath: (path: string) => void;
  setPassword: (pw: string) => void;
  setIsLoading: (loading: boolean) => void;
  runUnlock: () => Promise<void>;
  removeFile: () => void;
}

export const useUnlockStore = create<UnlockState>((set, get) => ({
  file: "",
  destinationPath: "",
  password: "",
  isLoading: false,

  setFile: (file) => set({ file }),
  setDestinationPath: (path) => set({ destinationPath: path }),
  setPassword: (pw) => set({ password: pw }),
  setIsLoading: (loading) => set({ isLoading: loading }),
  removeFile: () =>
    set({
      file: "",
      destinationPath: "",
      password: "",
      isLoading: false,
    }),

  runUnlock: async () => {
    const {
      file,
      destinationPath,
      password,
      isLoading,
      setIsLoading,
      removeFile,
    } = get();

    if (!file) {
      notifyWarning(
        i18next.t("tools:tools.unlock.notifications.warning.no_file"),
      );
      return;
    }
    if (!password) {
      notifyWarning(
        i18next.t("tools:tools.unlock.notifications.warning.no_password"),
      );
      return;
    }
    if (isLoading) return;

    setIsLoading(true);
    const result = await unlockPdf({
      inputPath: file,
      outputPath: destinationPath || "",
      password,
    });
    if (result.ok) {
      notifySuccess(i18next.t("tools:tools.unlock.notifications.success"));
      removeFile();
    } else {
      notifyError(
        result.error ?? i18next.t("tools:tools.unlock.notifications.error"),
      );
    }
    setIsLoading(false);
  },
}));
