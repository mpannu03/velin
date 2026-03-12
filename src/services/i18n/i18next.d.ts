import "i18next";
import common_en from "./en/common.json";
import home_en from "./en/home.json";
import reader_en from "./en/reader.json";
import tools_en from "./en/tools.json";
import settings_en from "./en/settings.json";

declare module "i18next" {
  interface CustomTypeOptions {
    resources: {
      common: typeof common_en;
      home: typeof home_en;
      reader: typeof reader_en;
      tools: typeof tools_en;
      settings: typeof settings_en;
    };
  }
}
