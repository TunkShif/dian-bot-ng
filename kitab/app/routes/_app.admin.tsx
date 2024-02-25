import { NavLink, Outlet } from "@remix-run/react"
import { Box, Flex, styled } from "styled-system/jsx"
import { flex, vstack } from "styled-system/patterns"
import { Heading } from "~/components/ui/heading"

export default function AdminLayout() {
  return (
    <Box w="full" position="relative">
      <SideBar />
      <Box ml="44">
        <Outlet />
      </Box>
    </Box>
  )
}

const NAVIGATIONS = [
  { name: "消息通告", route: "/admin/broadcast" },
  { name: "权限管理", route: "/admin/permissions" }
]

const SideBar = () => {
  return (
    <Flex
      position="fixed"
      direction="column"
      left="var(--sidebar-width)"
      insetY="0"
      w="44"
      bg="bg.subtle"
      borderRightWidth="1"
    >
      <Box w="full" p="4" h="16" bg="bg.default" borderBottomWidth="1">
        <Heading as="h1" fontFamily="silkscreen" size="lg">
          Systems
        </Heading>
      </Box>
      <Box w="full">
        <styled.nav py="14">
          <ul className={vstack({ gap: "1", py: "4", alignItems: "start" })}>
            {NAVIGATIONS.map(({ name, route }) => (
              <styled.li w="full">
                <NavLink
                  to={route}
                  className={flex({
                    alignItems: "center",
                    w: "calc(100% - {sizes.4})",
                    h: "12",
                    px: "6",
                    py: "2",
                    fontSize: "sm",
                    fontWeight: "medium",
                    roundedRight: "lg",
                    _hover: { bg: "accent.emphasized", color: "accent.fg" },
                    _focus: { bg: "accent.emphasized", color: "accent.fg" },
                    _focusVisible: {
                      outlineColor: "accent.emphasized",
                      outlineStyle: "solid",
                      outlineWidth: "2px",
                      outlineOffset: "2px"
                    },
                    _currentPage: {
                      bg: "accent.emphasized",
                      color: "accent.fg"
                    }
                  })}
                >
                  {name}
                </NavLink>
              </styled.li>
            ))}
          </ul>
        </styled.nav>
      </Box>
    </Flex>
  )
}
