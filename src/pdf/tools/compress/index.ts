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
  labelKey: string;
  value: CompressLevel;
  descriptionKey: string;
}[] = [
  {
    labelKey: "tools.compress.levels.extreme.label",
    value: "extreme",
    descriptionKey: "tools.compress.levels.extreme.description",
  },
  {
    labelKey: "tools.compress.levels.recommended.label",
    value: "recommended",
    descriptionKey: "tools.compress.levels.recommended.description",
  },
  {
    labelKey: "tools.compress.levels.less.label",
    value: "less",
    descriptionKey: "tools.compress.levels.less.description",
  },
  {
    labelKey: "tools.compress.levels.custom.label",
    value: "custom",
    descriptionKey: "tools.compress.levels.custom.description",
  },
];
