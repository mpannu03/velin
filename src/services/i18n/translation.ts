import common_en from "./en/common.json";
import home_en from "./en/home.json";
import reader_en from "./en/reader.json";
import tools_en from "./en/tools.json";

export const resources = {
  en: {
    common: common_en,
    home: home_en,
    reader: reader_en,
    tools: tools_en,
  },
} as const;
