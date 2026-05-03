// Keep non-Chinese languages sorted by code, then append Chinese variants as: zh, yue, lzh.
export const SUPPORTED_LOCALES = ["de", "el", "en", "es", "fr", "ja", "ru", "tr", "zh", "yue", "lzh"] as const;

export const LANGUAGES = [
  { code: "de", label: "Deutsch" },
  { code: "el", label: "Ελληνικά" },
  { code: "en", label: "English" },
  { code: "es", label: "Español" },
  { code: "fr", label: "Français" },
  { code: "ja", label: "日本語" },
  { code: "ru", label: "Русский" },
  { code: "tr", label: "Türkçe" },
  { code: "zh", label: "中文" },
  { code: "yue", label: "粵語" },
  { code: "lzh", label: "文言文" },
] as const;
