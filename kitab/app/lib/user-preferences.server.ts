import { createCookie } from "@remix-run/cloudflare"
import { z } from "zod"

export const userPreferencesSchema = z.object({
  sidebarCollapsed: z.boolean().default(false)
})

export type UserPreferencesSchema = z.infer<typeof userPreferencesSchema>

export const userPreferencesCookie = createCookie("__user_prefs", { maxAge: 7 * 24 * 60 * 60 })

export const getUserPreferences = async (request: Request) => {
  const cookie = (await userPreferencesCookie.parse(request.headers.get("Cookie"))) || {}
  const prefs = userPreferencesSchema.parse(cookie)
  return prefs
}

export const setUserPrefrences = (preferences: UserPreferencesSchema) =>
  userPreferencesCookie.serialize(preferences)
