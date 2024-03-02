import { defineConfig } from "@pandacss/dev"
import { createPreset } from "@park-ui/panda-preset"

export default defineConfig({
  presets: [
    "@pandacss/preset-base",
    createPreset({
      grayColor: "mauve",
      accentColor: "red",
      borderRadius: "md",
      additionalColors: ["tomato", "grass"]
    })
  ],
  theme: {
    extend: {
      tokens: {
        fonts: {
          cinzel: { value: "var(--font-cinzel), serif" },
          silkscreen: { value: "var(--font-silkscreen), serif" }
        }
      },
      recipes: {
        button: {
          variants: {
            size: {
              "2xs": {
                h: "6",
                minW: "6",
                textStyle: "xs",
                px: "2.5",
                gap: "2",
                "& svg": {
                  fontSize: "md",
                  width: "4",
                  height: "4"
                }
              }
            }
          }
        }
      },
      slotRecipes: {
        card: {
          base: {
            root: {
              boxShadow: "none",
              borderWidth: "1px"
            }
          }
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
