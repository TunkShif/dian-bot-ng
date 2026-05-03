import { defineConfig } from 'i18next-cli'

export default defineConfig({
  locales: [
    "en",
    "es",
    "de",
    "fr",
    "ja",
    "zh"
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
