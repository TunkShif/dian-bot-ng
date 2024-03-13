import { type LoaderFunctionArgs, defer, redirect } from "@remix-run/cloudflare"
import { Outlet, useLoaderData, useNavigation, useRouteLoaderData } from "@remix-run/react"
import { useAtom } from "jotai"
import { useMemo } from "react"
import { css } from "styled-system/css"
import { styled } from "styled-system/jsx"
import { center } from "styled-system/patterns"
import invariant from "tiny-invariant"
import { Link as StyledLink } from "~/components/ui/link"
import { Text } from "~/components/ui/text"
import { createToast } from "~/lib/toast.server"
import { createSetupTrackerEffect } from "~/lib/trackers"
import { BotStatusQuery } from "~/queries/bot-status"
import { CurrentUserQuery } from "~/queries/current-user"
import { UserActivitiesQuery } from "~/queries/user-activities"
import { ActivityTrackers } from "~/routes/_app/activity-trackers"
import { BottomBar, Sidebar, TopBar, useIsCollapsed } from "~/routes/_app/sidebar"

import "@fontsource/silkscreen/700.css"

export const useAppLoaderData = () => useLoaderData<typeof loader>()

export const useAppRouteLoaderData = () => useRouteLoaderData<typeof loader>("routes/_app")

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const currentUserResult = await client.query(CurrentUserQuery, {}).toPromise()
  const currentUser = currentUserResult.data?.me
  if (!currentUser?.user) {
    const headers = await createToast({
      type: "error",
      title: "访问受限",
      description: "游客用户请先登录哦~"
    })
    return redirect("/auth/signin", { headers })
  }
  invariant(currentUser.token)

  const userActivitiesQuery = client.query(UserActivitiesQuery, { first: 20 }).toPromise()

  const botQuery = await client.query(BotStatusQuery, {}).toPromise()
  const isBotOnline = botQuery.data?.bot.isOnline ?? false

  const env = {
    baseUrl: context.env.HAFIZ_SOCKET_URL
  }

  return defer({
    env,
    now: new Date(),
    isBotOnline,
    userActivitiesQuery,
    token: currentUser.token,
    currentUser: currentUser.user,
    permissions: currentUser.perms
  })
}

export default function AppLayout() {
  const isCollapsed = useIsCollapsed()

  const {
    env: { baseUrl },
    token
  } = useAppLoaderData()

  const setupTrackerEffect = useMemo(
    () => createSetupTrackerEffect(baseUrl, token),
    [baseUrl, token]
  )

  useAtom(setupTrackerEffect)

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
      <TopBar />

      <Sidebar />
      <Main />
      <Footer />

      <BottomBar />

      <ActivityTrackers />
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
        , made with ❤
      </Text>
    </footer>
  )
}
