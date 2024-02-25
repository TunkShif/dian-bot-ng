import { createCookie } from "@remix-run/cloudflare"
import { z } from "zod"

export const userPreferencesSchema = z.object({
  sidebarCollapsed: z.boolean().default(true)
})

export type UserPreferencesSchema = z.infer<typeof userPreferencesSchema>

export const userPreferencesCookie = createCookie("__user_prefs", {
  maxAge: 365 * 24 * 60 * 60,
  path: "/",
  httpOnly: true,
  sameSite: "lax"
})

export const getUserPreferences = async (request: Request) => {
  const cookie = (await userPreferencesCookie.parse(request.headers.get("Cookie"))) || {}
  const prefs = userPreferencesSchema.parse(cookie)
  return prefs
}

export const setUserPreferences = async (preferences: UserPreferencesSchema) => {
  return new Headers({ "Set-Cookie": await userPreferencesCookie.serialize(preferences) })
}
