import { logDevReady } from "@remix-run/cloudflare"
import { createPagesFunctionHandler } from "@remix-run/cloudflare-pages"
import * as build from "@remix-run/dev/server-build"
import { environmentSchema, type EnvironmentSchema } from "~/lib/environment.server"
import { createSessionStorage, type SessionStorage } from "~/lib/session.server"

if (process.env.NODE_ENV === "development") {
  logDevReady(build)
}

declare module "@remix-run/cloudflare" {
  interface AppLoadContext {
    env: EnvironmentSchema
    sessionStorage: SessionStorage
  }
}

// TODO: migrate to Remix 2.7.0
export const onRequest = createPagesFunctionHandler({
  build,
  getLoadContext: (context) => {
    const env = environmentSchema.parse(context.env)
    const sessionStorage = createSessionStorage(env.SESSION_SECRET)
    return { env, sessionStorage }
  },
  mode: build.mode
})
