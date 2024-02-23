import { type Session, createCookieSessionStorage } from "@remix-run/cloudflare"

type SessionData = {
  token: string
}

type SessionFlashData = {}

export type SessionStorage = ReturnType<typeof createSessionStorage>

export const createSessionStorage = (secret: string) => {
  type CurrentSession = Session<SessionData, SessionFlashData>

  const sessionStorage = createCookieSessionStorage<SessionData, SessionFlashData>({
    cookie: {
      name: "__session",
      path: "/",
      httpOnly: true,
      maxAge: 20 * 24 * 60 * 60,
      sameSite: "lax",
      secrets: [secret],
      secure: true
    }
  })

  const getSession = async (request: Request) => {
    return sessionStorage.getSession(request.headers.get("Cookie"))
  }

  const commitSession = async (session: CurrentSession) =>
    new Headers({ "Set-Cookie": await sessionStorage.commitSession(session) })

  return { getSession, commitSession }
}
