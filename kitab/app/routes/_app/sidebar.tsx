import { Link, NavLink, useFetcher, useRouteLoaderData } from "@remix-run/react"
import {
  ArchiveIcon,
  GaugeIcon,
  ImageIcon,
  PanelLeftCloseIcon,
  PanelLeftOpenIcon,
  SearchIcon,
  SettingsIcon,
  UserIcon
} from "lucide-react"
import { css } from "styled-system/css"
import { Box, Center, Flex, styled } from "styled-system/jsx"
import { flex, vstack } from "styled-system/patterns"
import invariant from "tiny-invariant"
import { z } from "zod"
import { Logo } from "~/components/logo"
import { Badge } from "~/components/ui/badge"
import { Button } from "~/components/ui/button"
import { Icon } from "~/components/ui/icon"
import { IconButton } from "~/components/ui/icon-button"
import { Text } from "~/components/ui/text"
import { type loader as rootLoader } from "~/root"

const NAVIGATIONS = [
  { name: "我的首页", icon: GaugeIcon, route: "/dashboard" },
  { name: "精华典库", icon: ArchiveIcon, route: "/archive" },
  { name: "精彩图库", icon: ImageIcon, route: "/gallery" },
  { name: "个人账户", icon: UserIcon, route: "/account" },
  { name: "更多设置", icon: SettingsIcon, route: "/settings" }
]

const SIDEBAR_FETCHER_KEY = "SIDEBAR_FETCHER"

export const sidebarFormSchema = z.object({
  collapsed: z.string().transform((val) => val === "true")
})

export const useIsCollapsed = () => {
  const data = useRouteLoaderData<typeof rootLoader>("root")
  invariant(data?.userPreferences, "No user preferences found in root loader data.")
  let collapsed = data.userPreferences.sidebarCollapsed
  const optimisticValue = useOptimisticIsCollapsed()
  if (optimisticValue !== undefined) {
    collapsed = optimisticValue
  }
  return collapsed
}

const useOptimisticIsCollapsed = () => {
  const fetcher = useFetcher({ key: SIDEBAR_FETCHER_KEY })
  if (fetcher.formData) {
    const parsed = sidebarFormSchema.parse(Object.fromEntries(fetcher.formData.entries()))
    return parsed.collapsed
  }
}

export const Sidebar = () => {
  return (
    <Flex
      direction="column"
      w="var(--sidebar-width)"
      position="fixed"
      top="0"
      bottom="0"
      left="0"
      borderRightWidth="1px"
    >
      <Box position="relative" pt="4" px="4">
        <BrandSection />
        <NavSection />
      </Box>
    </Flex>
  )
}

const BrandSection = () => {
  return (
    <Flex
      h="12"
      mx="-4"
      px="4"
      pb="4"
      borderBottomWidth="1px"
      justify="space-between"
      align="center"
      className={css({
        "[data-sidebar-collapsed=true] &": {
          h: "auto",
          gap: "2",
          flexDirection: "column"
        }
      })}
    >
      <BrandLogo />
      <CollapseToggle />
    </Flex>
  )
}

const BrandLogo = () => (
  <Link to="/" className={flex({ align: "center" })}>
    <Logo width="32" height="32" />
    <Text
      ml="1"
      fontFamily="silkscreen"
      textTransform="uppercase"
      letterSpacing="tight"
      className={css({ "[data-sidebar-collapsed=true] &": { display: "none" } })}
    >
      Little Red Book
    </Text>
  </Link>
)

const CollapseToggle = () => {
  const fetcher = useFetcher({ key: SIDEBAR_FETCHER_KEY })
  const isCollapsed = useIsCollapsed()

  return (
    <fetcher.Form method="post" action="/actions/preferences">
      <IconButton variant="ghost" type="submit" name="collapsed" value={(!isCollapsed).toString()}>
        {isCollapsed ? <PanelLeftOpenIcon /> : <PanelLeftCloseIcon />}
      </IconButton>
    </fetcher.Form>
  )
}

const NavSection = () => (
  <Flex
    mx="-4"
    px="4"
    py="4"
    direction="column"
    gap="4"
    borderBottomWidth="1px"
    className={css({
      "[data-sidebar-collapsed=true] &": {
        alignItems: "center"
      }
    })}
  >
    <Button
      variant="outline"
      justifyContent="space-between"
      className={css({
        "[data-sidebar-collapsed=true] &": {
          paddingX: "0",
          justifyContent: "center",
          marginInline: "2"
        }
      })}
    >
      <styled.span display="inline-flex">
        <SearchIcon className={css({ color: "fg.default" })} />
        <styled.span
          ml="2"
          color="fg.subtle"
          className={css({
            "[data-sidebar-collapsed=true] &": {
              display: "none"
            }
          })}
        >
          搜索 Anything
        </styled.span>
      </styled.span>
      <Badge
        className={css({
          "[data-sidebar-collapsed=true] &": {
            display: "none"
          }
        })}
      >
        CTRL + K
      </Badge>
    </Button>
    <nav>
      <styled.ul className={vstack({ gap: "1" })}>
        {NAVIGATIONS.map(({ name, icon: NavIcon, route }) => (
          <styled.li key={name} w="full">
            <NavLink
              to={route}
              className={flex({
                p: "2",
                gap: "4",
                align: "center",
                rounded: "lg",
                _hover: { bg: "accent.2" },
                _focus: { bg: "accent.2" },
                _focusVisible: {
                  outlineColor: "accent.emphasized",
                  outlineStyle: "solid",
                  outlineWidth: "2px",
                  outlineOffset: "2px"
                },
                _currentPage: {
                  bg: "accent.emphasized",
                  _hover: {
                    bg: "accent.emphasized"
                  },
                  _focus: {
                    bg: "accent.emphasized"
                  },
                  "& [data-nav-label]": { color: "white" }
                },
                "[data-sidebar-collapsed=true] &": {
                  flexDirection: "column",
                  gap: "2",
                  justifyContent: "center"
                }
              })}
            >
              <Center w="8" h="8" bg="accent.4" rounded="md">
                <Icon color="accent.text">
                  <NavIcon />
                </Icon>
              </Center>
              <styled.span
                data-nav-label
                fontSize="sm"
                fontWeight="medium"
                className={css({
                  "[data-sidebar-collapsed=true] &": {
                    display: "none"
                  }
                })}
              >
                {name}
              </styled.span>
            </NavLink>
          </styled.li>
        ))}
      </styled.ul>
    </nav>
  </Flex>
)
