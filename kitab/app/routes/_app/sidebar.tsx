import { Portal } from "@ark-ui/react"
import { Form, Link, NavLink, useFetcher, useRouteLoaderData } from "@remix-run/react"
import {
  ArchiveIcon,
  BookLockIcon,
  BotIcon,
  GaugeIcon,
  ImageIcon,
  LogOutIcon,
  PanelLeftCloseIcon,
  PanelLeftOpenIcon,
  SearchIcon,
  SettingsIcon,
  UserIcon
} from "lucide-react"
import { css, cx } from "styled-system/css"
import { Box, Center, Circle, Flex, Stack, styled } from "styled-system/jsx"
import { center, flex, hstack, vstack } from "styled-system/patterns"
import invariant from "tiny-invariant"
import { z } from "zod"
import { Logo } from "~/components/logo"
import { ThemeToggleButton } from "~/components/theme"
import { Badge } from "~/components/ui/badge"
import { Button } from "~/components/ui/button"
import { Icon } from "~/components/ui/icon"
import { IconButton } from "~/components/ui/icon-button"
import { Text } from "~/components/ui/text"
import * as Tooltip from "~/components/ui/tooltip"
import type { loader as rootLoader } from "~/root"
import { OnlineUsers } from "~/routes/_app/online-users"
import type { loader as appLoader } from "~/routes/_app/route"

const NAVIGATIONS = [
  { name: "我的首页", icon: GaugeIcon, route: "/dashboard" },
  { name: "精华典库", icon: ArchiveIcon, route: "/archive" },
  { name: "精彩图库", icon: ImageIcon, route: "/gallery" },
  { name: "后台管理", icon: BookLockIcon, route: "/admin" },
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
      display="none"
      bg="bg.default"
      lg={{ display: "flex" }}
      direction="column"
      justify="space-between"
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
      <Box position="relative" pb="4" px="4">
        <BottomSection />
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
      userSelect="none"
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
    <fetcher.Form method="post" action="/actions/preferences" className={center()}>
      <Tooltip.Root openDelay={150}>
        <Tooltip.Trigger asChild>
          <IconButton
            variant="ghost"
            type="submit"
            name="collapsed"
            value={(!isCollapsed).toString()}
          >
            {isCollapsed ? <PanelLeftOpenIcon /> : <PanelLeftCloseIcon />}
          </IconButton>
        </Tooltip.Trigger>
        <Portal>
          <Tooltip.Positioner>
            <Tooltip.Content>{isCollapsed ? "展开面板" : "收起面板"}</Tooltip.Content>
          </Tooltip.Positioner>
        </Portal>
      </Tooltip.Root>
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
    <SearchButton />
    <nav>
      <ul className={vstack({ gap: "1" })}>
        {NAVIGATIONS.map((nav) => (
          <styled.li key={nav.name} w="full">
            <NavItem {...nav} />
          </styled.li>
        ))}
      </ul>
    </nav>
  </Flex>
)

const SearchButton = () => {
  const isCollapsed = useIsCollapsed()

  return (
    <Tooltip.Root disabled={!isCollapsed} positioning={{ placement: "right-end" }}>
      <Tooltip.Trigger asChild>
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
      </Tooltip.Trigger>
      <Portal>
        <Tooltip.Positioner>
          <Tooltip.Content>搜索 Anything</Tooltip.Content>
        </Tooltip.Positioner>
      </Portal>
    </Tooltip.Root>
  )
}

const navStyles = flex({
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
    "& [data-nav-label]": { color: "accent.fg" }
  }
})

const NavItem = ({ name, route, icon: NavIcon }: (typeof NAVIGATIONS)[number]) => {
  const isCollapsed = useIsCollapsed()

  return (
    <Tooltip.Root disabled={!isCollapsed} positioning={{ placement: "right-end" }}>
      <Tooltip.Trigger asChild>
        <NavLink
          to={route}
          prefetch="intent"
          className={cx(
            navStyles,
            css({
              "[data-sidebar-collapsed=true] &": {
                flexDirection: "column",
                gap: "2",
                justifyContent: "center"
              }
            })
          )}
        >
          <Center w="8" h="8" bg="accent.4" rounded="md">
            <Icon color="accent.text" _dark={{ color: "accent.12" }}>
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
      </Tooltip.Trigger>
      <Portal>
        <Tooltip.Positioner>
          <Tooltip.Content>{name}</Tooltip.Content>
        </Tooltip.Positioner>
      </Portal>
    </Tooltip.Root>
  )
}

const BottomSection = () => {
  return (
    <Stack
      direction="row"
      justify="end"
      gap="1"
      className={css({ "[data-sidebar-collapsed=true] &": { flexDirection: "column" } })}
    >
      <CollapseToggle />
      <BotStatus />
      <OnlineUsers />
      <ThemeToggleButton />
      <SignOutButton />
    </Stack>
  )
}

const BotStatus = () => {
  const data = useRouteLoaderData<typeof appLoader>("routes/_app")
  invariant(data, "App route data is missing")
  const isBotOnline = data.isBotOnline

  return (
    <Center>
      <Tooltip.Root openDelay={150}>
        <Tooltip.Trigger asChild>
          <IconButton position="relative" variant="ghost">
            <BotIcon />
            <Circle
              data-active={isBotOnline || undefined}
              position="absolute"
              top="0"
              right="0"
              bg="tomato.8"
              size="1.5"
              _active={{ bg: "grass.8" }}
            />
          </IconButton>
        </Tooltip.Trigger>
        <Portal>
          <Tooltip.Positioner>
            <Tooltip.Content>{isBotOnline ? "Bot 状态在线" : "Bot 似乎挂了"}</Tooltip.Content>
          </Tooltip.Positioner>
        </Portal>
      </Tooltip.Root>
    </Center>
  )
}

const SignOutButton = () => (
  <Form method="delete" action="/auth/signout" className={center()}>
    <Tooltip.Root>
      <Tooltip.Trigger asChild>
        <IconButton variant="ghost" type="submit">
          <LogOutIcon />
        </IconButton>
      </Tooltip.Trigger>
      <Portal>
        <Tooltip.Positioner>
          <Tooltip.Content>退出登录</Tooltip.Content>
        </Tooltip.Positioner>
      </Portal>
    </Tooltip.Root>
  </Form>
)

export const BottomBar = () => {
  return (
    <Box
      position="fixed"
      insetX="0"
      bottom="0"
      borderTopWidth="1px"
      bg="bg.default"
      lg={{ display: "none" }}
    >
      <styled.nav p="2" md={{ px: "8" }}>
        <ul className={hstack({ gap: "1", justifyContent: "space-between" })}>
          {NAVIGATIONS.map(({ name, route, icon: NavIcon }) => (
            <styled.li key={name}>
              <NavLink
                to={route}
                className={cx(navStyles, css({ flexDirection: "column", gap: "1.5" }))}
              >
                <Center w="8" h="8" bg="accent.4" rounded="md">
                  <Icon color="accent.text">
                    <NavIcon />
                  </Icon>
                </Center>
                <styled.span
                  data-nav-label
                  fontSize="xs"
                  fontWeight="medium"
                  textAlign="center"
                  maxW="4ch"
                  md={{ maxW: "none" }}
                >
                  {name}
                </styled.span>
              </NavLink>
            </styled.li>
          ))}
        </ul>
      </styled.nav>
    </Box>
  )
}
