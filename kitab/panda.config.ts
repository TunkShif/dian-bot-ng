import { defineConfig } from "@pandacss/dev"
import { createPreset } from "@park-ui/panda-preset"

export default defineConfig({
  presets: [
    "@pandacss/preset-base",
    createPreset({
      grayColor: "sage",
      accentColor: "tomato",
      borderRadius: "lg",
      additionalColors: ["sage", "tomato"]
    })
  ],
  preflight: true,
  jsxFramework: "react",
  outdir: "styled-system",
  outExtension: "js",
  include: ["./app/routes/**/*.{ts,tsx,js,jsx}", "./app/components/**/*.{ts,tsx,js,jsx}"],
  exclude: []
})
