import { redirect, type LoaderFunctionArgs } from "@remix-run/cloudflare"
import { Outlet, useNavigation } from "@remix-run/react"
import { graphql } from "gql"
import { css } from "styled-system/css"
import { styled } from "styled-system/jsx"
import { Link as StyledLink } from "~/components/ui/link"
import { Text } from "~/components/ui/text"
import { createToast } from "~/lib/toast.server"
import { BottomBar, Sidebar, useIsCollapsed } from "~/routes/_app/sidebar"
import { CurrentUserQuery } from "~/services/auth-service"

import "@fontsource/silkscreen/700.css"
import { center } from "styled-system/patterns"

const BotStatusQuery = graphql(`
  query BotStatus {
    bot {
      isOnline
    }
  }
`)

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const userQuery = await client.query(CurrentUserQuery, {}).toPromise()
  const user = userQuery.data?.me
  if (!user) {
    const headers = await createToast({
      type: "error",
      title: "访问受限",
      description: "游客用户请先登录哦~"
    })
    return redirect("/auth/signin", { headers })
  }

  const botQuery = await client.query(BotStatusQuery, {}).toPromise()
  const isBotOnline = botQuery.data?.bot.isOnline ?? false

  return { currentUser: user, isBotOnline }
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
      <Footer />
      <BottomBar />
    </div>
  )
}

const Main = () => {
  const navigation = useNavigation()
  const isNavigating = navigation.state === "loading"

  return (
    <styled.main
      lg={{
        ml: "var(--sidebar-width)"
      }}
      data-loading={isNavigating || undefined}
      aria-busy={isNavigating}
      _loading={{ opacity: "65%" }}
    >
      <Outlet />
    </styled.main>
  )
}

const Footer = () => {
  return (
    <footer
      className={center({
        pt: "6",
        pb: "32",
        lg: { pb: "6", ml: "var(--sidebar-width)" },
        flexDirection: "column",
        gap: "2",
        borderTopWidth: "1"
      })}
    >
      <Text size="sm" fontFamily="silkscreen" color="accent.text">
        little red book
      </Text>
      <Text size="sm">
        📕 Powered by
        <StyledLink mx="0.5" href="https://github.com/TunkShif/dian-bot-ng/" target="_blank">
          dian-bot-ng
        </StyledLink>
        , made with ❤️
      </Text>
    </footer>
  )
}
