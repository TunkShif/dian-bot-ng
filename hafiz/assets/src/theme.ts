import { createTheme } from "@mantine/core"
import { themeToVars } from "@mantine/vanilla-extract"

export const theme = createTheme({
  primaryColor: "red",
  fontFamily: "'Figtree Variable', system-ui, sans-serif"
})

export const vars = themeToVars(theme)
