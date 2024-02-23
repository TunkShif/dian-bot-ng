import { json, redirect, type ActionFunctionArgs } from "@remix-run/cloudflare"
import { AuthService } from "~/services/auth-service"

export const action = async ({ request, context }: ActionFunctionArgs) => {
  if (request.method !== "DELETE") {
    return json({ ok: false }, { status: 405 })
  }

  const service = new AuthService(context.client.httpClient)
  await service.signOut()
  const headers = await context.sessionStorage.destroySession(request)
  return redirect("/auth/signin", { headers })
}
