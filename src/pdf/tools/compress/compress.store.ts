import {
  notifyError,
  notifySuccess,
  notifyWarning,
} from "@/services/notifications";
import { compressPdf } from "@/services/tauri";
import { create } from "zustand";
import i18next from "@/services/i18n/i18n";

export type CompressLevel = "extreme" | "recommended" | "less" | "custom";

export const getCompressQuality = (level: CompressLevel, customValue: number): number => {
  switch (level) {
    case "extreme":
      return 30; // 30% quality, heavily downsamples
    case "recommended":
      return 60; // 60% quality, medium downsampling
    case "less":
      return 100; // 100% quality, only structural compression
    case "custom":
      return customValue;
  }
};

interface CompressState {
  file: string | null;
  level: CompressLevel;
  customQuality: number;
  destinationPath: string;
  isLoading: boolean;
  setFile: (filePath: string | null) => void;
  setLevel: (level: CompressLevel) => void;
  setCustomQuality: (quality: number) => void;
  setDestinationPath: (path: string) => void;
  setIsLoading: (loading: boolean) => void;
  runCompress: () => Promise<void>;
}

export const useCompressState = create<CompressState>((set, get) => ({
  file: null,
  level: "recommended",
  customQuality: 70,
  destinationPath: "",
  isLoading: false,

  setFile: (file: string | null) => set({ file }),
  
  setLevel: (level: CompressLevel) => set({ level }),
  
  setCustomQuality: (customQuality: number) => set({ customQuality }),

  setDestinationPath: (path: string) => set({ destinationPath: path }),

  setIsLoading: (loading: boolean) => set({ isLoading: loading }),

  runCompress: async () => {
    const { file, level, customQuality, destinationPath, isLoading, setIsLoading, setFile } = get();
    
    if (file && destinationPath && !isLoading) {
      setIsLoading(true);
      const quality = getCompressQuality(level, customQuality);
      const result = await compressPdf(file, destinationPath, quality);
      
      if (result.ok) {
        notifySuccess(i18next.t("tools:tools.compress.notifications.success") || "PDF compressed successfully");
        setFile(null);
      } else {
        notifyError(
          result.error ?? (i18next.t("tools:tools.compress.notifications.error") || "Failed to compress PDF"),
        );
      }
      setIsLoading(false);
    } else {
      notifyWarning(i18next.t("tools:tools.compress.notifications.warning") || "Please select a file and a destination");
    }
  },
}));
