import { ActionFunctionArgs, json } from "@remix-run/cloudflare"
import { getUserPreferences, setUserPreferences } from "~/lib/user-preferences.server"
import { sidebarFormSchema } from "~/routes/_app/sidebar"

export const action = async ({ request }: ActionFunctionArgs) => {
  const userPreferences = await getUserPreferences(request)
  const formData = sidebarFormSchema.parse(Object.fromEntries((await request.formData()).entries()))
  const data = {
    ...userPreferences,
    sidebarCollapsed: formData.collapsed
  }

  const headers = await setUserPreferences(data)

  return json(data, { headers })
}
