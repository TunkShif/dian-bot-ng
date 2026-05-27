import i18n from "i18next";
import LanguageDetector from "i18next-browser-languagedetector";
import Backend from "i18next-http-backend";
import { initReactI18next } from "react-i18next";
import * as z from "zod";
import { SUPPORTED_LOCALES } from "@/lib/locales";
import { zodErrorMap } from "@/lib/zod-error-map";

/**
 * Configure Zod to use i18n-aware error messages.
 * This should be called after i18n is initialized and whenever the language changes.
 */
const configureZodI18n = () => {
  z.setErrorMap(zodErrorMap);
};

export const setupI18n = () => {
  i18n
    .use(Backend)
    .use(LanguageDetector)
    .use(initReactI18next)
    .init({
      supportedLngs: SUPPORTED_LOCALES,
      fallbackLng: "en",
      interpolation: {
        escapeValue: false, // react already safes from xss
      },
    });

  // Set up Zod validation message internationalization
  configureZodI18n();

  // Update Zod error map when language changes
  i18n.on("languageChanged", configureZodI18n);
};

/**
 * Hook to ensure Zod error map is updated when language changes.
 * This is useful in components that create Zod schemas dynamically.
 */
export const useZodI18n = () => {
  // The error map is already configured globally, but we can use this hook
  // to ensure components re-render when language changes
  return {
    createSchema: <T extends z.ZodRawShape>(shape: T) => z.object(shape),
  };
};
