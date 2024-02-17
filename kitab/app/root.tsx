import type { LinksFunction, LoaderFunctionArgs } from "@remix-run/cloudflare"
import { cssBundleHref } from "@remix-run/css-bundle"
import { Links, LiveReload, Meta, Outlet, Scripts, ScrollRestoration, json } from "@remix-run/react"
import styles from "./index.css"

import "@fontsource-variable/inter/wght.css"
import { getUserPreferences, setUserPrefrences } from "~/lib/user-preferences.server"

export const links: LinksFunction = () => [
  ...(cssBundleHref ? [{ rel: "stylesheet", href: cssBundleHref }] : []),
  { rel: "stylesheet", href: styles },
  { rel: "icon", href: "/favicon.svg" }
]

export const loader = async ({ request }: LoaderFunctionArgs) => {
  const userPreferences = await getUserPreferences(request)

  const data = {
    userPreferences
  }

  const headers = new Headers()
  headers.append("Set-Cookie", await setUserPrefrences(userPreferences))

  return json(data, { headers })
}

export default function App() {
  return (
    <html lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
        <Outlet />
        <ScrollRestoration />
        <Scripts />
        <LiveReload />
      </body>
    </html>
  )
}
