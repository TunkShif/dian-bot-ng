import { redirect, type LoaderFunctionArgs } from "@remix-run/cloudflare"
import { Outlet } from "@remix-run/react"
import { css } from "styled-system/css"
import { styled } from "styled-system/jsx"
import { createToast } from "~/lib/toast.server"
import { BottomBar, Sidebar, useIsCollapsed } from "~/routes/_app/sidebar"
import { CurrentUserQuery } from "~/services/auth-service"

import "@fontsource/silkscreen/700.css"

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const { data } = await client.query(CurrentUserQuery, {}).toPromise()
  if (!data || !data.me.user) {
    const headers = await createToast({
      type: "error",
      title: "访问受限",
      description: "游客用户请先登录哦~"
    })
    return redirect("/auth/signin", { headers })
  }

  return { currentUser: data.me.user }
}

export default function AppLayout() {
  const isCollapsed = useIsCollapsed()

  return (
    <div
      className={css({
        "--sidebar-width": "{sizes.72}",
        "&[data-sidebar-collapsed=true]": {
          "--sidebar-width": "{sizes.20}"
        }
      })}
      data-sidebar-collapsed={isCollapsed}
    >
      <Sidebar />
      <Main />
      <BottomBar />
    </div>
  )
}

const Main = () => {
  return (
    <styled.main
      lg={{
        ml: "var(--sidebar-width)"
      }}
    >
      <Outlet />
    </styled.main>
  )
}
