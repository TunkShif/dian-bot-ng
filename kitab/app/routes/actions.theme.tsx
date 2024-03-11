import { parseWithZod } from "@conform-to/zod"
import { type ActionFunctionArgs, json } from "@remix-run/cloudflare"
import { themeFormSchema } from "~/components/theme"
import { setUserTheme } from "~/lib/theme.server"

export const action = async ({ request }: ActionFunctionArgs) => {
  const formData = await request.formData()
  const submission = parseWithZod(formData, { schema: themeFormSchema })

  if (submission.status !== "success") {
    return submission.reply()
  }

  const headers = await setUserTheme(submission.value.theme)

  return json(submission.reply(), { headers })
}
