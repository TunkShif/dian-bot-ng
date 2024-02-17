import { ActionFunctionArgs, json } from "@remix-run/cloudflare"
import { getUserPreferences, setUserPrefrences } from "~/lib/user-preferences.server"
import { sidebarFormSchema } from "~/routes/_app/sidebar"

export const action = async ({ request }: ActionFunctionArgs) => {
  const userPreferences = await getUserPreferences(request)
  const formData = sidebarFormSchema.parse(Object.fromEntries((await request.formData()).entries()))
  const data = {
    ...userPreferences,
    sidebarCollapsed: formData.collapsed
  }

  const headers = new Headers()
  headers.append("Set-Cookie", await setUserPrefrences(data))

  return json(data, { headers })
}
