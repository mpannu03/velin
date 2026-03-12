import i18next from "i18next";
import { initReactI18next } from "react-i18next";
import { DEFAULT_LANGUAGE } from "./languages";
import { resources } from "./translation";

const lng = navigator.language.split("-")[0];
const supportedLngs = Object.keys(resources);

i18next.use(initReactI18next).init({
  resources,
  lng: supportedLngs.includes(lng) ? lng : DEFAULT_LANGUAGE,
  fallbackLng: DEFAULT_LANGUAGE,
  supportedLngs,
  ns: ["common", "home", "reader", "tools", "settings"],
  defaultNS: "common",
  keySeparator: ".",
  nsSeparator: ":",
  interpolation: {
    escapeValue: false,
  },
  debug: true,
});

export default i18next;
