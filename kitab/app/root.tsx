import type { LinksFunction, LoaderFunctionArgs } from "@remix-run/cloudflare"
import { cssBundleHref } from "@remix-run/css-bundle"
import {
  Links,
  LiveReload,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
  json,
  useLoaderData
} from "@remix-run/react"
import { Toaster } from "sonner"
import { styled } from "styled-system/jsx"
import { useToast } from "~/components/toaster"
import { combineHeaders } from "~/lib/helpers"
import { getToast } from "~/lib/toast.server"
import { getUserPreferences, setUserPreferences } from "~/lib/user-preferences.server"
import styles from "./index.css"

import "@fontsource-variable/inter/wght.css"
import { useTheme } from "~/components/theme"
import { ClientHintCheck, getHints } from "~/lib/client-hints"
import { getUserTheme } from "~/lib/theme.server"

export const links: LinksFunction = () => [
  ...(cssBundleHref ? [{ rel: "stylesheet", href: cssBundleHref }] : []),
  { rel: "stylesheet", href: styles },
  { rel: "icon", href: "/favicon.svg" }
]

export const loader = async ({ request }: LoaderFunctionArgs) => {
  const [toast, theme, userPreferences] = await Promise.all([
    getToast(request),
    getUserTheme(request),
    getUserPreferences(request)
  ])

  const headers = combineHeaders(toast.headers, await setUserPreferences(userPreferences))

  return json(
    {
      hints: getHints(request),
      toast: toast.toast,
      theme,
      userPreferences
    },
    { headers }
  )
}

export default function App() {
  const { toast } = useLoaderData<typeof loader>()
  const theme = useTheme()

  useToast(toast)

  return (
    <html lang="en" className={theme}>
      <head>
        <ClientHintCheck nonce="" />
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <styled.body position="relative">
        <Outlet />
        <Toaster position="top-center" toastOptions={{ duration: 3500 }} closeButton richColors />
        <ScrollRestoration />
        <Scripts />
        <LiveReload />
      </styled.body>
    </html>
  )
}
