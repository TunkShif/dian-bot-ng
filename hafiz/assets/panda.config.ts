import { defineConfig } from "@pandacss/dev"
import { createPreset } from "@park-ui/panda-preset"

export default defineConfig({
  preflight: true,
  presets: [
    "@pandacss/preset-base",
    createPreset({
      grayColor: "mauve",
      accentColor: "tomato",
      borderRadius: "md",
      additionalColors: ["tomato", "gold", "jade"]
    })
  ],
  include: ["./src/**/*.{js,jsx,ts,tsx}"],
  exclude: [],
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
  jsxFramework: "react",
  outdir: "styled-system"
})
