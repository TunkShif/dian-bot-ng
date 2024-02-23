import { logDevReady } from "@remix-run/cloudflare"
import { createPagesFunctionHandler } from "@remix-run/cloudflare-pages"
import * as build from "@remix-run/dev/server-build"
import { type ClientContext, createClientContext } from "~/lib/client.server"
import { environmentSchema, type EnvironmentSchema } from "~/lib/environment.server"
import { createSessionStorage, type SessionStorage } from "~/lib/session.server"

if (process.env.NODE_ENV === "development") {
  logDevReady(build)
}

declare module "@remix-run/cloudflare" {
  interface AppLoadContext {
    env: EnvironmentSchema
    client: ClientContext
    sessionStorage: SessionStorage
  }
}

// TODO: migrate to Remix 2.7.0
export const onRequest = createPagesFunctionHandler({
  build,
  getLoadContext: async (context) => {
    const env = environmentSchema.parse(context.env)
    const client = createClientContext(env.HAFIZ_API_URL)
    const sessionStorage = createSessionStorage(env.SESSION_SECRET)

    return { env, client, sessionStorage }
  },
  mode: build.mode
})
