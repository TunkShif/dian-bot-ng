import { Outlet } from "@remix-run/react"
import { Stack } from "styled-system/jsx"

export default function NotificationTemplate() {
  return (
    <Stack p="2">
      <Outlet />
    </Stack>
  )
}
