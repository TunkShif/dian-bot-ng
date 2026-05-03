import { useCallback } from "react";
import { useTranslation } from "react-i18next";
import { LANGUAGES, SUPPORTED_LOCALES } from "@/lib/locales";

export const useLanguage = () => {
  const { i18n } = useTranslation();
  const currentLanguage =
    SUPPORTED_LOCALES.find((locale) => i18n.language?.startsWith(locale)) ??
    SUPPORTED_LOCALES.find((locale) => i18n.resolvedLanguage?.startsWith(locale)) ??
    "en";
  const currentLanguageLabel =
    LANGUAGES.find((language) => language.code === currentLanguage)?.label ?? currentLanguage.toUpperCase();

  const changeLanguage = useCallback(
    (language: string) => {
      void i18n.changeLanguage(language);
    },
    [i18n],
  );

  return {
    languages: LANGUAGES,
    currentLanguage,
    currentLanguageLabel,
    changeLanguage,
  };
};
