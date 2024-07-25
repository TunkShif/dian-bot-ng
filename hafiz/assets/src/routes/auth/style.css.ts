import { rem } from "@mantine/core"
import { style } from "@vanilla-extract/css"
import { vars } from "~/theme"

export const container = style({
  display: "grid",
  height: "100vh",
  "@media": {
    [vars.smallerThan("md")]: {
      gridTemplateRows: "repeat(12, minmax(0, 1fr))"
    },
    [vars.largerThan("md")]: {
      gridTemplateColumns: "repeat(12, minmax(0, 1fr))"
    }
  }
})

export const coverContainer = style({
  position: "relative",
  "@media": {
    [vars.smallerThan("md")]: {
      gridRow: "span 4 / span 4"
    },
    [vars.largerThan("md")]: {
      gridColumn: "span 7 / span 7"
    }
  }
})

export const coverWrapper = style({
  position: "absolute",
  inset: 0,
  overflow: "hidden"
})

export const coverPlaceholder = style({
  position: "absolute",
  inset: 0,
  width: "100%",
  height: "100%",
  objectFit: "cover",
  filter: "blur(16px) sepia(25%) grayscale(15%) brightness(60%)",
  transform: "scale(1.1)",
  zIndex: -1
})

export const coverImage = style({
  width: "100%",
  height: "100%",
  filter: "sepia(25%) grayscale(15%) brightness(60%)"
})

export const coverSource = style({
  position: "absolute",
  top: rem(16),
  left: rem(16)
})

export const coverText = style({
  position: "absolute",
  bottom: rem(16),
  right: rem(16),
  selectors: {
    "&::before": {
      content: "open-quote"
    },
    "&::after": {
      content: "close-quote"
    }
  }
})

export const formContainer = style({
  position: "relative",
  padding: rem(16),
  "@media": {
    [vars.smallerThan("md")]: {
      gridRow: "span 8 / span 8",
      selectors: {
        "&::before": {
          content: " ",
          position: "absolute",
          top: rem(-16),
          insetInline: 0,
          height: rem(16),
          background: vars.colors.body,
          borderStartStartRadius: vars.radius.md,
          borderStartEndRadius: vars.radius.md
        }
      }
    },
    [vars.largerThan("md")]: {
      padding: rem(36),
      gridColumn: "span 5 / span 5"
    }
  }
})
