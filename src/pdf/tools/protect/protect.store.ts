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
  assembly: boolean;
  commenting: boolean;
  copying: boolean;
}

interface ProtectState {
  file: string;
  destinationPath: string;
  password: string;
  permissions: Permissions;
  isLoading: boolean;
  setFile: (file: string) => void;
  setDestinationPath: (path: string) => void;
  setPassword: (pw: string) => void;
  togglePermission: (key: keyof Permissions) => void;
  setIsLoading: (loading: boolean) => void;
  runProtect: () => Promise<void>;
  removeFile: () => void;
}

export const useProtectStore = create<ProtectState>((set, get) => ({
  file: "",
  destinationPath: "",
  password: "",
  permissions: {
    printing: false,
    assembly: false,
    commenting: false,
    copying: false,
  },
  isLoading: false,

  setFile: (file) => set({ file }),
  setDestinationPath: (path) => set({ destinationPath: path }),
  setPassword: (pw) => set({ password: pw }),
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
      permissions: {
        printing: false,
        assembly: false,
        commenting: false,
        copying: false,
      },
      isLoading: false,
    }),

  runProtect: async () => {
    const {
      file,
      destinationPath,
      password,
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
    console.log(permissions);
    const result = await protectPdf({
      inputPath: file,
      outputPath: destinationPath || "",
      password,
      allowPrinting: permissions.printing,
      allowAssembly: permissions.assembly,
      allowCommenting: permissions.commenting,
      allowCopying: permissions.copying,
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
