import { CompressLevel } from "./compress.store";

export * from "./Compress";

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
