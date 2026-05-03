import i18n from "i18next";
import LanguageDetector from "i18next-browser-languagedetector";
import Backend from "i18next-http-backend";
import { initReactI18next } from "react-i18next";

export const setupI18n = () => {
  i18n
    .use(Backend)
    .use(LanguageDetector)
    .use(initReactI18next)
    .init({
      supportedLngs: ["en", "zh"],
      fallbackLng: "en",
      interpolation: {
        escapeValue: false, // react already safes from xss
      },
    });
};
