import "i18next";
import { resources } from "./translation";
import common_en from "./en/common.json";
import home_en from "./en/home.json";

declare module "i18next" {
  interface CustomTypeOptions {
    resources: {
      common: typeof common_en;
      home: typeof home_en;
    };
  }
}
