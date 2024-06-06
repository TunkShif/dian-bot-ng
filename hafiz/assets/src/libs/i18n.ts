import i18next from "i18next"
import HttpBackend from "i18next-http-backend"
import { initReactI18next } from "react-i18next"

await i18next
  .use(HttpBackend)
  .use(initReactI18next)
  .init({
    debug: import.meta.env.DEV,
    fallbackLng: "zh",
    ns: ["common", "validation", "auth"],
    defaultNS: "common"
  })

export const i18n = i18next
