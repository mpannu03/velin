import common_en from "./en/common.json";
import home_en from "./en/home.json";
import reader_en from "./en/reader.json";
import tools_en from "./en/tools.json";
import common_hi from "./hi/common.json";
import home_hi from "./hi/home.json";
import reader_hi from "./hi/reader.json";
import tools_hi from "./hi/tools.json";

export const resources = {
  en: {
    common: common_en,
    home: home_en,
    reader: reader_en,
    tools: tools_en,
  },
  hi: {
    common: common_hi,
    home: home_hi,
    reader: reader_hi,
    tools: tools_hi,
  },
} as const;
