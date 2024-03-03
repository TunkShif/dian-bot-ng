import type { LoaderFunctionArgs, MetaFunction } from "@remix-run/cloudflare"
import { Link, Outlet, redirect, useLocation, useNavigate } from "@remix-run/react"
import { Center, Stack } from "styled-system/jsx"
import { Heading } from "~/components/ui/heading"
import * as Tabs from "~/components/ui/tabs"

export const meta: MetaFunction = () => {
  return [{ title: "Admin - LITTLE RED BOOK" }]
}

export const loader = ({ request }: LoaderFunctionArgs) => {
  const url = new URL(request.url)
  const segments = url.pathname.split("/").filter((it) => !!it)
  const isLayoutRoute = segments.length === 1 && segments[0] === "admin"
  if (isLayoutRoute) return redirect("/admin/notification-template") // TODO: change this later
  return { ok: true }
}

const TABS = [
  { key: "user-management", label: "用户管理" },
  { key: "notification-template", label: "通知管理" },
  { key: "pinned-messages", label: "站内公告" },
  { key: "message-broadcast", label: "消息广播" }
] as const

const DEFAULT_TAB = "message-broadcast"

export default function AdminLayout() {
  const location = useLocation()
  const navigate = useNavigate()

  const segments = location.pathname.split("/").filter((it) => !!it)
  const maybeTab = segments[1]
  const activeTab = !!maybeTab ? maybeTab : DEFAULT_TAB

  return (
    <Center mx="4" py="4" lg={{ py: "8" }}>
      <Stack w="full" maxW="5xl" gap="6">
        <Link to="/admin">
          <Heading
            color="accent.emphasized"
            w="full"
            fontFamily="silkscreen"
            fontSize="2xl"
            as="h2"
          >
            Administration
          </Heading>
        </Link>

        <Tabs.Root
          variant="outline"
          value={activeTab}
          onValueChange={({ value }) => navigate(value === activeTab ? "" : value)}
        >
          <Tabs.List>
            {TABS.map(({ key, label }) => (
              <Tabs.Trigger key={key} value={key} asChild>
                <Link to={key}>{label}</Link>
              </Tabs.Trigger>
            ))}
            <Tabs.Indicator />
          </Tabs.List>
          <Tabs.Content value={activeTab}>
            <Outlet />
          </Tabs.Content>
        </Tabs.Root>
      </Stack>
    </Center>
  )
}
