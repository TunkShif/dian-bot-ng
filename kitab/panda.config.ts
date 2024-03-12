import { defineConfig } from "@pandacss/dev"
import { createPreset } from "@park-ui/panda-preset"

export default defineConfig({
  presets: [
    "@pandacss/preset-base",
    createPreset({
      grayColor: "mauve",
      accentColor: "red",
      borderRadius: "md",
      additionalColors: ["tomato", "gold", "jade"]
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
        },
        iconButton: {
          variants: {
            size: {
              "2xs": {
                w: "6",
                h: "6",
                minW: "6",
                minH: "6",
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
  include: ["./app/**/*.{ts,tsx,js,jsx}"],
  exclude: []
})
