import { createId as cuid2 } from "@paralleldrive/cuid2"
import { createCookieSessionStorage } from "@remix-run/cloudflare"
import { z } from "zod"

export const toastSchema = z.object({
  id: z
    .string()
    .cuid2()
    .default(() => cuid2()),
  type: z.enum(["default", "success", "error"]).default("default"),
  title: z.string(),
  description: z.string().optional()
})

export type ToastSchema = z.infer<typeof toastSchema>
export type ToastInputSchema = z.input<typeof toastSchema>

type SessionData = {}
type SessionFlashData = { toast: ToastSchema }

export const toastsSessionStorage = createCookieSessionStorage<SessionData, SessionFlashData>({
  cookie: {
    name: "__toasts",
    maxAge: 20 * 60,
    path: "/",
    httpOnly: true,
    sameSite: "lax",
    secrets: ["Lcl1DaZKp9l3fA4o0BifVgSY1heBqbHM6uEkXuzYgw6OZtoQKphrtj/M/l8cKf6s"],
    secure: true
  }
})

export const createToast = async (toastOptions: ToastInputSchema) => {
  const session = await toastsSessionStorage.getSession()
  const toast = toastSchema.parse(toastOptions)
  session.flash("toast", toast)
  return new Headers({ "Set-Cookie": await toastsSessionStorage.commitSession(session) })
}

export const getToast = async (request: Request) => {
  const session = await toastsSessionStorage.getSession(request.headers.get("Cookie"))
  const result = toastSchema.safeParse(session.get("toast"))
  const toast = result.success ? result.data : null
  const headers = toast
    ? new Headers({ "Set-Cookie": await toastsSessionStorage.destroySession(session) })
    : null
  return {
    toast,
    headers
  }
}
