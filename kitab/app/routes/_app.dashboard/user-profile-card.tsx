import { Portal } from "@ark-ui/react"
import { useLoaderData } from "@remix-run/react"
import { UserRole } from "gql/graphql"
import { MessageSquareIcon, StickerIcon, UsersRoundIcon } from "lucide-react"
import { Center, Flex, Grid, HStack, VStack } from "styled-system/jsx"
import invariant from "tiny-invariant"
import { RoleBadge } from "~/components/shared/role-badge"
import { Avatar } from "~/components/ui/avatar"
import { Badge } from "~/components/ui/badge"
import * as Card from "~/components/ui/card"
import { Icon } from "~/components/ui/icon"
import { Text } from "~/components/ui/text"
import * as Tooltip from "~/components/ui/tooltip"
import type { loader as dashboardLoader } from "~/routes/_app.dashboard/route"
import { useAppRouteLoaderData } from "~/routes/_app/route"

export const UserProfileCard = () => {
  return (
    <Card.Root w="full" maxW="sm">
      <Card.Header>
        <Card.Title>Profile</Card.Title>
      </Card.Header>
      <Card.Body>
        <UserInfo />
      </Card.Body>
      <Card.Footer pt="6" px="2" borderTopWidth="1">
        <UserStatistics />
      </Card.Footer>
    </Card.Root>
  )
}

const UserInfo = () => {
  const data = useAppRouteLoaderData()
  invariant(data, "App loader data is missing.")
  const user = data.currentUser

  return (
    <Flex direction="column">
      <HStack>
        <Avatar size="2xl" src={`/avatar/${user.qid}`} name={user.name} borderWidth="1" />
        <VStack alignItems="start">
          <Flex gap="2" alignItems="center">
            <RoleBadge userRole={user.role} />
            <Text maxW="10ch" truncate title={user.name}>
              {user.name}
            </Text>
          </Flex>
          <HStack gap="1">
            <Text size="sm">QID:</Text>
            <Text size="sm" color="fg.subtle">
              ({user.qid})
            </Text>
          </HStack>
        </VStack>
      </HStack>
    </Flex>
  )
}

const USER_STATISTICS = [
  { key: "chats", label: "发言", icon: MessageSquareIcon, description: "我的逆天言论" },
  { key: "threads", label: "入典", icon: StickerIcon, description: "我记录的黑历史" },
  { key: "followers", label: "敌蜜", icon: UsersRoundIcon, description: "偷窥我的情敌" }
] as const

const UserStatistics = () => {
  const { userStatistics } = useLoaderData<typeof dashboardLoader>()

  return (
    <Grid w="full" columns={3} gap="0" divideX="1">
      {USER_STATISTICS.map(({ key, label, icon: LabelIcon, description }) => (
        <Center key={key}>
          <VStack>
            <Tooltip.Root openDelay={200}>
              <Tooltip.Trigger asChild>
                <VStack gap="1.5">
                  <Icon size="lg">
                    <LabelIcon />
                  </Icon>
                  <Text size="xs" color="fg.subtle" fontWeight="medium">
                    {label}
                  </Text>
                </VStack>
              </Tooltip.Trigger>
              <Portal>
                <Tooltip.Positioner>
                  <Tooltip.Content>{description}</Tooltip.Content>
                </Tooltip.Positioner>
              </Portal>
            </Tooltip.Root>
            <Text size="lg" fontWeight="semibold" fontVariantNumeric="tabular-nums">
              {userStatistics[key]}
            </Text>
          </VStack>
        </Center>
      ))}
    </Grid>
  )
}
