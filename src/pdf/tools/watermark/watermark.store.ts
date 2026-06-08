import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import { watermarkPdf } from "@/services/tauri";
import { create } from "zustand";
import i18next from "@/services/i18n/i18n";

export type WatermarkType = "text" | "image";
export type WatermarkPosition =
  | "center"
  | "top-left"
  | "top-right"
  | "bottom-left"
  | "bottom-right";

export interface WatermarkState {
  file: string;
  destinationPath: string;
  watermarkType: WatermarkType;
  text: string;
  fontSize: number;
  fontColor: string;
  imagePath: string;
  imageScale: number;
  opacity: number;
  rotation: number;
  position: WatermarkPosition;
  xOffset: number;
  yOffset: number;
  pagesMode: "all" | "select";
  pageSelection: string;
  isLoading: boolean;

  setFile: (file: string) => void;
  setDestinationPath: (path: string) => void;
  setWatermarkType: (type: WatermarkType) => void;
  setText: (text: string) => void;
  setFontSize: (size: number) => void;
  setFontColor: (color: string) => void;
  setImagePath: (path: string) => void;
  setImageScale: (scale: number) => void;
  setOpacity: (opacity: number) => void;
  setRotation: (rotation: number) => void;
  setPosition: (position: WatermarkPosition) => void;
  setXOffset: (offset: number) => void;
  setYOffset: (offset: number) => void;
  setPagesMode: (mode: "all" | "select") => void;
  setPageSelection: (selection: string) => void;
  setIsLoading: (loading: boolean) => void;
  removeFile: () => void;
  runWatermark: () => Promise<void>;
}

export const useWatermarkStore = create<WatermarkState>((set, get) => ({
  file: "",
  destinationPath: "",
  watermarkType: "text",
  text: "",
  fontSize: 48,
  fontColor: "#808080",
  imagePath: "",
  imageScale: 0.5,
  opacity: 0.3,
  rotation: 0,
  position: "center",
  xOffset: 0,
  yOffset: 0,
  pagesMode: "all",
  pageSelection: "",
  isLoading: false,

  setFile: (file: string) => set({ file }),
  setDestinationPath: (path: string) => set({ destinationPath: path }),
  setWatermarkType: (type: WatermarkType) => set({ watermarkType: type }),
  setText: (text: string) => set({ text }),
  setFontSize: (size: number) => set({ fontSize: size }),
  setFontColor: (color: string) => set({ fontColor: color }),
  setImagePath: (path: string) => set({ imagePath: path }),
  setImageScale: (scale: number) => set({ imageScale: scale }),
  setOpacity: (opacity: number) => set({ opacity }),
  setRotation: (rotation: number) => set({ rotation }),
  setPosition: (position: WatermarkPosition) => set({ position }),
  setXOffset: (offset: number) => set({ xOffset: offset }),
  setYOffset: (offset: number) => set({ yOffset: offset }),
  setPagesMode: (pagesMode) => set({ pagesMode }),
  setPageSelection: (selection: string) => set({ pageSelection: selection }),
  setIsLoading: (loading: boolean) => set({ isLoading: loading }),

  removeFile: () =>
    set({
      file: "",
      destinationPath: "",
      text: "",
      imagePath: "",
      pageSelection: "",
      pagesMode: "all",
    }),

  runWatermark: async () => {
    const {
      file,
      destinationPath,
      watermarkType,
      text,
      fontSize,
      fontColor,
      imagePath,
      imageScale,
      opacity,
      rotation,
      position,
      xOffset,
      yOffset,
      pagesMode,
      pageSelection,
      isLoading,
      removeFile,
      setIsLoading,
    } = get();

    if (!file) {
      notifyWarning(
        i18next.t("tools:tools.watermark.notifications.warning.no_file", {
          defaultValue: "Please select a PDF file to watermark.",
        }),
      );
      return;
    }

    if (!destinationPath) {
      notifyWarning(
        i18next.t(
          "tools:tools.watermark.notifications.warning.no_destination",
          {
            defaultValue: "Please select a destination file.",
          },
        ),
      );
      return;
    }

    if (watermarkType === "text" && !text.trim()) {
      notifyWarning(
        i18next.t("tools:tools.watermark.notifications.warning.no_text", {
          defaultValue: "Please enter watermark text.",
        }),
      );
      return;
    }

    if (watermarkType === "image" && !imagePath) {
      notifyWarning(
        i18next.t("tools:tools.watermark.notifications.warning.no_image", {
          defaultValue: "Please select a watermark image.",
        }),
      );
      return;
    }

    if (isLoading) return;

    setIsLoading(true);
    const result = await watermarkPdf({
      inputPath: file,
      outputPath: destinationPath,
      watermarkType,
      text: text || null,
      fontSize: fontSize || null,
      fontColor: fontColor || null,
      imagePath: imagePath || null,
      imageScale: imageScale || null,
      opacity,
      rotation,
      position,
      xOffset: xOffset || null,
      yOffset: yOffset || null,
      pages: pagesMode === "all" ? null : pageSelection || null,
    });

    if (result.ok) {
      notifySuccess(
        i18next.t("tools:tools.watermark.notifications.success", {
          defaultValue: "Watermark added successfully.",
        }),
      );
      removeFile();
    } else {
      notifyError(
        result.error ??
          i18next.t("tools:tools.watermark.notifications.error", {
            defaultValue: "Failed to add watermark.",
          }),
      );
    }
    setIsLoading(false);
  },
}));
