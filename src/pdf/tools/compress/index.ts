export * from "./Compress";

export type CompressLevel = "extreme" | "recommended" | "less" | "custom";

export const getCompressQuality = (
  level: CompressLevel,
  customValue: number,
): number => {
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

export const LEVELS: {
  label: string;
  value: CompressLevel;
  description: string;
}[] = [
  {
    label: "Extreme",
    value: "extreme",
    description:
      "Highest compression, lowest quality (images downsampled to ~30%)",
  },
  {
    label: "Recommended",
    value: "recommended",
    description: "Good compression, high quality (images compressed to 60%)",
  },
  {
    label: "Less",
    value: "less",
    description: "Low compression, best quality (only structural compression)",
  },
  {
    label: "Custom",
    value: "custom",
    description: "Manually choose the image compression quality",
  },
];
