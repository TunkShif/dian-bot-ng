import { Portal } from "@ark-ui/react"
import { intlFormatDistance } from "date-fns"
import { atom, useAtom, useAtomValue, useSetAtom } from "jotai"
import { ChevronDownIcon, UsersRoundIcon, XIcon } from "lucide-react"
import { css } from "styled-system/css"
import { Box, Center, HStack, Stack, styled } from "styled-system/jsx"
import { stack } from "styled-system/patterns"
import { Tooltip } from "~/components/shared/tooltip"
import { Avatar } from "~/components/ui/avatar"
import { Button } from "~/components/ui/button"
import * as Collapsible from "~/components/ui/collapsible"
import { Icon } from "~/components/ui/icon"
import { IconButton } from "~/components/ui/icon-button"
import * as Popover from "~/components/ui/popover"
import { Switch } from "~/components/ui/switch"
import { Text } from "~/components/ui/text"
import {
  type OnlineUser,
  onlineUsersAtom,
  showHistoryActivityAtom,
  showOnlineActivityAtom
} from "~/lib/trackers"

const nowAtom = atom(new Date())

export const OnlineUsers = () => {
  const setNow = useSetAtom(nowAtom)

  return (
    <Popover.Root
      positioning={{ placement: "right" }}
      onOpenChange={({ open }) => {
        open && setNow(new Date())
      }}
    >
      <Popover.Trigger asChild>
        <Center>
          <Tooltip content="在线用户">
            <IconButton variant="ghost">
              <UsersRoundIcon />
            </IconButton>
          </Tooltip>
        </Center>
      </Popover.Trigger>

      <Portal>
        <Popover.Positioner>
          <Popover.Content minW="2xs">
            <Popover.Arrow>
              <Popover.ArrowTip />
            </Popover.Arrow>

            <Stack gap="2">
              <Popover.Title>在线用户列表</Popover.Title>

              <Stack maxH="xs" overflowY="auto">
                <OnlineUsersList />
              </Stack>

              <ActivityDisplaySettings />
            </Stack>

            <Box position="absolute" top="1" right="1">
              <Popover.CloseTrigger asChild>
                <IconButton aria-label="关闭用户列表弹窗" variant="ghost" size="xs">
                  <XIcon />
                </IconButton>
              </Popover.CloseTrigger>
            </Box>
          </Popover.Content>
        </Popover.Positioner>
      </Portal>
    </Popover.Root>
  )
}

const OnlineUsersList = () => {
  const onlineUsers = useAtomValue(onlineUsersAtom)

  return (
    <ul className={stack({ divideY: "1px", gap: "0" })}>
      {onlineUsers.map((user) => (
        <styled.li key={user.id} py="2" _first={{ pt: "0" }} _last={{ pb: "0" }}>
          <OnlineUserItem user={user} />
        </styled.li>
      ))}
    </ul>
  )
}

const OnlineUserItem = ({ user }: { user: OnlineUser }) => {
  const now = useAtomValue(nowAtom)
  const distance = intlFormatDistance(user.onlineAt, now, { locale: "zh-Hans-CN" })
  const status = distance === "现在" ? "在线" : "上线"

  return (
    <HStack gap="2">
      <Avatar borderWidth="1" src={`/avatar/${user.qid}`} name={user.name} />
      <Stack gap="0.5">
        <Text size="md" fontWeight="medium">
          {user.name}
        </Text>
        <Text size="sm">
          {distance}
          {status}
        </Text>
      </Stack>
    </HStack>
  )
}

const ActivityDisplaySettings = () => {
  const [showOnlineActivity, setShowOnlineActivity] = useAtom(showOnlineActivityAtom)
  const [showHistoryActivity, setShowHistoryActivity] = useAtom(showHistoryActivityAtom)

  return (
    <Box mx="-4" px="4" pt="2" borderTopWidth="1">
      <Collapsible.Root>
        <Collapsible.Trigger asChild>
          <Button variant="link" size="sm">
            用户足迹显示设置
            <Icon
              className={css({
                "[data-scope='collapsible'][data-state='open'] &": {
                  rotate: "-180deg"
                }
              })}
            >
              <ChevronDownIcon />
            </Icon>
          </Button>
        </Collapsible.Trigger>
        <Collapsible.Content>
          <Stack pt="2" gap="1.5">
            <HStack justify="space-between">
              <Text size="sm">显示在线用户实时动态</Text>
              <Switch
                size="sm"
                checked={showOnlineActivity}
                onCheckedChange={({ checked }) => setShowOnlineActivity(checked)}
              />
            </HStack>

            <HStack justify="space-between">
              <Text size="sm">显示用户历史足迹</Text>
              <Switch
                size="sm"
                checked={showHistoryActivity}
                onCheckedChange={({ checked }) => setShowHistoryActivity(checked)}
              />
            </HStack>
          </Stack>
        </Collapsible.Content>
      </Collapsible.Root>
    </Box>
  )
}
