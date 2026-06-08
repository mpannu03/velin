import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import i18next from "@/services/i18n/i18n";
import { create } from "zustand";
import { protectPdf } from "@/services/tauri";

interface Permissions {
  printing: boolean;
  highQualityPrinting: boolean;
  modifying: boolean;
  copying: boolean;
  annotating: boolean;
  formFilling: boolean;
  assembly: boolean;
}

const DEFAULT_PERMISSIONS: Permissions = {
  printing: false,
  highQualityPrinting: false,
  modifying: false,
  copying: false,
  annotating: false,
  formFilling: false,
  assembly: false,
};

interface ProtectState {
  file: string;
  destinationPath: string;
  password: string;
  confirmPassword: string;
  requirePasswordToOpen: boolean;
  permissions: Permissions;
  isLoading: boolean;
  setFile: (file: string) => void;
  setDestinationPath: (path: string) => void;
  setPassword: (pw: string) => void;
  setConfirmPassword: (pw: string) => void;
  setRequirePasswordToOpen: (value: boolean) => void;
  togglePermission: (key: keyof Permissions) => void;
  setIsLoading: (loading: boolean) => void;
  runProtect: () => Promise<void>;
  removeFile: () => void;
}

export const useProtectStore = create<ProtectState>((set, get) => ({
  file: "",
  destinationPath: "",
  password: "",
  confirmPassword: "",
  requirePasswordToOpen: false,
  permissions: { ...DEFAULT_PERMISSIONS },
  isLoading: false,

  setFile: (file) => set({ file }),
  setDestinationPath: (path) => set({ destinationPath: path }),
  setPassword: (pw) => set({ password: pw }),
  setConfirmPassword: (pw) => set({ confirmPassword: pw }),
  setRequirePasswordToOpen: (value) => set({ requirePasswordToOpen: value }),
  togglePermission: (key) =>
    set((state) => ({
      permissions: { ...state.permissions, [key]: !state.permissions[key] },
    })),
  setIsLoading: (loading) => set({ isLoading: loading }),
  removeFile: () =>
    set({
      file: "",
      destinationPath: "",
      password: "",
      confirmPassword: "",
      requirePasswordToOpen: false,
      permissions: { ...DEFAULT_PERMISSIONS },
      isLoading: false,
    }),

  runProtect: async () => {
    const {
      file,
      destinationPath,
      password,
      requirePasswordToOpen,
      permissions,
      isLoading,
      setIsLoading,
      removeFile,
    } = get();

    if (!file) {
      notifyWarning(
        i18next.t("tools:tools.protect.notifications.warning.no_file"),
      );
      return;
    }
    if (!password) {
      notifyWarning(
        i18next.t("tools:tools.protect.notifications.warning.no_password"),
      );
      return;
    }
    if (isLoading) return;

    setIsLoading(true);
    const result = await protectPdf({
      inputPath: file,
      outputPath: destinationPath || "",
      password,
      requirePasswordToOpen,
      allowPrinting: permissions.printing,
      allowHighQualityPrinting: permissions.highQualityPrinting,
      allowModifying: permissions.modifying,
      allowCopying: permissions.copying,
      allowAnnotating: permissions.annotating,
      allowFormFilling: permissions.formFilling,
      allowAssembly: permissions.assembly,
    });
    if (result.ok) {
      notifySuccess(i18next.t("tools:tools.protect.notifications.success"));
      removeFile();
    } else {
      notifyError(
        result.error ?? i18next.t("tools:tools.protect.notifications.error"),
      );
    }
    setIsLoading(false);
  },
}));
