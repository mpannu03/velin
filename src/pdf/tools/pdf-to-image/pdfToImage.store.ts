import { create } from "zustand";
import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import { pdfToImg } from "@/services/tauri";
import i18next from "@/services/i18n/i18n";
import { ImageMode, ImageType } from ".";

interface PdfToImageState {
  file: string;
  selection: string;
  format: ImageType;
  dpi: number;
  quality: number;
  mode: ImageMode;
  pattern: string;
  destinationDir: string;
  isLoading: boolean;

  setFile: (file: string) => void;
  setSelection: (selection: string) => void;
  setFormat: (format: ImageType) => void;
  setDpi: (dpi: number) => void;
  setQuality: (quality: number) => void;
  setMode: (mode: ImageMode) => void;
  setPattern: (pattern: string) => void;
  setDestinationDir: (dir: string) => void;
  removeFile: () => void;
  setIsLoading: (loading: boolean) => void;
  runPdfToImage: () => Promise<void>;
}

export const usePdfToImageStore = create<PdfToImageState>((set, get) => ({
  file: "",
  selection: "",
  format: "png",
  dpi: 300,
  quality: 90,
  mode: "color",
  pattern: "page_{n}",
  destinationDir: "",
  isLoading: false,

  setFile: (file: string) => set({ file }),
  setSelection: (selection: string) => set({ selection }),
  setFormat: (format: ImageType) => set({ format }),
  setDpi: (dpi: number) => set({ dpi }),
  setQuality: (quality: number) => set({ quality }),
  setMode: (mode: ImageMode) => set({ mode }),
  setPattern: (pattern: string) => set({ pattern }),
  setDestinationDir: (dir: string) => set({ destinationDir: dir }),

  removeFile: () =>
    set({
      file: "",
      selection: "",
      destinationDir: "",
    }),

  setIsLoading: (loading: boolean) => set({ isLoading: loading }),

  runPdfToImage: async () => {
    const {
      file,
      selection,
      format,
      dpi,
      quality,
      mode,
      pattern,
      destinationDir,
      isLoading,
      setIsLoading,
    } = get();

    if (!file) {
      notifyWarning(
        i18next.t("tools:tools.pdf-to-image.notifications.warning.no_file"),
      );
      return;
    }

    if (!isLoading) {
      setIsLoading(true);
      const input = { file, selection: selection || "1-" };
      const currentDestDir =
        destinationDir ||
        file.substring(0, file.lastIndexOf(file.split(/[/\\]/).pop() || ""));

      const result = await pdfToImg(input, currentDestDir, {
        format,
        dpi,
        quality,
        mode,
        pattern,
      });

      if (result.ok) {
        notifySuccess(
          i18next.t("tools:tools.pdf-to-image.notifications.success"),
        );
      } else {
        notifyError(
          result.error ??
            i18next.t("tools:tools.pdf-to-image.notifications.error"),
        );
      }
      setIsLoading(false);
    }
  },
}));
