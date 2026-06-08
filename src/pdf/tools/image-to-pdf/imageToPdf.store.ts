import { create } from "zustand";
import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import { imagesToPdf } from "@/services/tauri";
import i18next from "@/services/i18n/i18n";
import { ImageToPdfPageSize, ImageToPdfOrientation, ImageToPdfFit } from ".";

interface ImageToPdfState {
  images: string[];
  pageSize: ImageToPdfPageSize;
  orientation: ImageToPdfOrientation;
  fit: ImageToPdfFit;
  margin: number;
  destinationPath: string;
  isLoading: boolean;

  setImages: (paths: string[]) => void;
  addImages: (paths: string[]) => void;
  removeImage: (path: string) => void;
  reorderImages: (paths: string[]) => void;
  setPageSize: (size: ImageToPdfPageSize) => void;
  setOrientation: (orientation: ImageToPdfOrientation) => void;
  setFit: (fit: ImageToPdfFit) => void;
  setMargin: (margin: number) => void;
  setDestinationPath: (path: string) => void;
  setIsLoading: (loading: boolean) => void;
  runImageToPdf: () => Promise<void>;
  reset: () => void;
}

export const useImageToPdfStore = create<ImageToPdfState>((set, get) => ({
  images: [],
  pageSize: "auto",
  orientation: "auto",
  fit: "contain",
  margin: 20,
  destinationPath: "",
  isLoading: false,

  setImages: (images: string[]) => set({ images }),

  addImages: (paths: string[]) =>
    set((prev) => {
      const existing = new Set(prev.images);
      const unique = paths.filter((p) => !existing.has(p));
      return { images: [...prev.images, ...unique] };
    }),

  removeImage: (path: string) =>
    set((prev) => ({
      images: prev.images.filter((p) => p !== path),
    })),

  reorderImages: (images: string[]) => set({ images }),

  setPageSize: (pageSize: ImageToPdfPageSize) => set({ pageSize }),

  setOrientation: (orientation: ImageToPdfOrientation) => set({ orientation }),

  setFit: (fit: ImageToPdfFit) => set({ fit }),

  setMargin: (margin: number) => set({ margin }),

  setDestinationPath: (path: string) => set({ destinationPath: path }),

  setIsLoading: (loading: boolean) => set({ isLoading: loading }),

  reset: () =>
    set({
      images: [],
      destinationPath: "",
      pageSize: "auto",
      orientation: "auto",
      fit: "contain",
      margin: 20,
    }),

  runImageToPdf: async () => {
    const {
      images,
      destinationPath,
      pageSize,
      orientation,
      fit,
      margin,
      isLoading,
      setIsLoading,
      reset,
    } = get();

    if (images.length === 0) {
      notifyWarning(
        i18next.t("tools:tools.image-to-pdf.notifications.warning.no_images"),
      );
      return;
    }

    if (!destinationPath) {
      notifyWarning(
        i18next.t(
          "tools:tools.image-to-pdf.notifications.warning.no_destination",
        ),
      );
      return;
    }

    if (!isLoading) {
      setIsLoading(true);
      const result = await imagesToPdf(images, destinationPath, {
        page_size: pageSize,
        orientation,
        fit,
        margin,
      });

      if (result.ok) {
        notifySuccess(
          i18next.t("tools:tools.image-to-pdf.notifications.success"),
        );
        reset();
      } else {
        notifyError(
          result.error ??
            i18next.t("tools:tools.image-to-pdf.notifications.error"),
        );
      }
      setIsLoading(false);
    }
  },
}));
