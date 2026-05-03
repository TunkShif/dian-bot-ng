import { defineConfig } from 'i18next-cli'

export default defineConfig({
  // Keep non-Chinese languages sorted by code, then append Chinese variants as: zh, yue, lzh.
  locales: [
    "de",
    "el",
    "en",
    "es",
    "fr",
    "ja",
    "ru",
    "tr",
    "zh",
    "yue",
    "lzh"
  ],
  extract: {
    input: "js/**/*.{js,jsx,ts,tsx}",
    ignore: ["js/components/ui/**/*", "js/client/**/*"],
    output: "public/locales/{{language}}/{{namespace}}.json"
  },
  types: {
    input: "public/locales/en/*.json",
    output: "js/types/i18n/locales.d.ts"
  }
})
