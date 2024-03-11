import { createCookie } from "@remix-run/cloudflare"
import { type ThemeSchema, themeSchema } from "~/components/theme"

export const themeCookie = createCookie("__user_theme", {
  maxAge: 365 * 24 * 60 * 60,
  path: "/",
  httpOnly: true,
  sameSite: "lax"
})

export const getUserTheme = async (reqeuest: Request) => {
  const cookie = (await themeCookie.parse(reqeuest.headers.get("Cookie"))) || "system"
  const theme = themeSchema.parse(cookie)
  return theme
}

export const setUserTheme = async (theme: ThemeSchema) => {
  let cookie = ""
  if (theme === "system") {
    cookie = await themeCookie.serialize("", { maxAge: -1 })
  } else {
    cookie = await themeCookie.serialize(theme)
  }
  return new Headers({ "Set-Cookie": cookie })
}
