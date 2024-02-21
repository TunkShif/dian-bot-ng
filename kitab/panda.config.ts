import { defineConfig } from "@pandacss/dev"
import { createPreset } from "@park-ui/panda-preset"

export default defineConfig({
  presets: [
    "@pandacss/preset-base",
    createPreset({
      grayColor: "mauve",
      accentColor: "red",
      borderRadius: "lg"
    })
  ],
  theme: {
    extend: {
      tokens: {
        fonts: {
          cinzel: { value: "var(--font-cinzel), serif" },
          silkscreen: { value: "var(--font-silkscreen), serif" }
        }
      }
    }
  },
  preflight: true,
  jsxFramework: "react",
  outdir: "styled-system",
  outExtension: "js",
  include: ["./app/routes/**/*.{ts,tsx,js,jsx}", "./app/components/**/*.{ts,tsx,js,jsx}"],
  exclude: []
})
