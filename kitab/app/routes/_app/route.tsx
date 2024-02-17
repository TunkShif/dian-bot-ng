import { Outlet } from "@remix-run/react"
import { css } from "styled-system/css"
import { styled } from "styled-system/jsx"
import { Sidebar } from "~/routes/_app/sidebar"

import "@fontsource/silkscreen/700.css"

export default function AppLayout() {
  return (
    <div
      className={css({
        "--sidebar-width": "{sizes.72}",
        "&[data-sidebar-collapsed=true]": {
          "--sidebar-width": "{sizes.20}"
        }
      })}
      data-sidebar-collapsed={true}
    >
      <Sidebar />
      <Main />
    </div>
  )
}

const Main = () => {
  return (
    <styled.main ml="var(--sidebar-width)">
      <Outlet />
    </styled.main>
  )
}
