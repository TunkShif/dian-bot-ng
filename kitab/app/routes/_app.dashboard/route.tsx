import { json, type LoaderFunctionArgs, type MetaFunction } from "@remix-run/cloudflare"
import { useLoaderData, useRouteLoaderData } from "@remix-run/react"
import { graphql } from "gql"
import { UserRole } from "gql/graphql"
import {
  ClipboardCheckIcon,
  ClipboardCopyIcon,
  InfoIcon,
  MessageSquareIcon,
  StickerIcon,
  UsersRoundIcon
} from "lucide-react"
import { Center, Flex, Grid, HStack, VStack } from "styled-system/jsx"
import invariant from "tiny-invariant"
import * as Alert from "~/components/ui/alert"
import { Avatar } from "~/components/ui/avatar"
import { Badge } from "~/components/ui/badge"
import * as Card from "~/components/ui/card"
import * as Clipboard from "~/components/ui/clipboard"
import { FormLabel } from "~/components/ui/form-label"
import { Icon } from "~/components/ui/icon"
import { IconButton } from "~/components/ui/icon-button"
import { Input } from "~/components/ui/input"
import { Text } from "~/components/ui/text"
import type { loader as appLoader } from "~/routes/_app/route"

export const meta: MetaFunction = () => {
  return [{ title: "Dashboard - LITTLE RED BOOK" }]
}

const DashboardQuery = graphql(`
  query DashboardQuery {
    me {
      statistics {
        chats
        threads
        followers
      }
    }
  }
`)

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)
  const { data } = await client.query(DashboardQuery, {}).toPromise()
  // TODO: unified invariant error handling
  invariant(data?.me)
  return json({
    statistics: data.me.statistics
  })
}

export default function Dashboard() {
  return (
    <Center w="full" pt="8">
      <Flex w="full" maxW="5xl" gap="8">
        <Flex flex="2" direction="column" gap="8">
          <PinnedMessages />
        </Flex>
        <Flex flex="1" direction="column" gap="8">
          <ProfileCard />
          <RssFeedCard />
        </Flex>
      </Flex>
    </Center>
  )
}

const PinnedMessages = () => {
  return (
    <VStack>
      <Alert.Root>
        <Alert.Icon asChild>
          <InfoIcon />
        </Alert.Icon>
        <Alert.Content>
          <Alert.Title>站点迁移升级通知</Alert.Title>
          <Alert.Description>
            本站正在完成全新版本的开发中，旧数据将陆续迁移导入。请耐心等待~
          </Alert.Description>
        </Alert.Content>
      </Alert.Root>
    </VStack>
  )
}

// TODO:
// 1. Most Recent Avtice User
// 2. Daily Activity Comparison
// 3. Heatmap
// 4. Weekly Statistics Line Chart
// 5. Followers

const ProfileCard = () => {
  const data = useRouteLoaderData<typeof appLoader>("routes/_app")
  invariant(data, "App loader data is missing.")
  const user = data.currentUser
  const isAdmin = user.role === UserRole.Admin

  const { statistics } = useLoaderData<typeof loader>()

  return (
    <Card.Root maxW="xs">
      <Card.Header>
        <Card.Title>Profile</Card.Title>
      </Card.Header>
      <Card.Body>
        <Flex direction="column">
          <HStack>
            <Avatar size="2xl" src={`/avatar/${user.qid}`} name={user.name} borderWidth="1" />
            <VStack alignItems="start">
              {isAdmin ? (
                <Badge variant="solid">SVIP</Badge>
              ) : (
                <Badge variant="solid">普通用户</Badge>
              )}
              <HStack>
                <Text maxW="10ch" truncate title={user.name}>
                  {user.name}
                </Text>
                <Text size="sm" color="fg.subtle">
                  ({user.qid})
                </Text>
              </HStack>
            </VStack>
          </HStack>
        </Flex>
      </Card.Body>
      <Card.Footer pt="6" px="2" borderTopWidth="1">
        <Grid w="full" columns={3} gap={0} divideX="1">
          <Center>
            <VStack>
              <VStack gap="1.5">
                <Icon size="lg">
                  <MessageSquareIcon />
                </Icon>
                <Text size="xs" color="fg.subtle" fontWeight="medium">
                  发言
                </Text>
              </VStack>
              <Text size="lg" fontVariantNumeric="tabular-nums">
                {statistics.chats}
              </Text>
            </VStack>
          </Center>

          <Center>
            <VStack>
              <VStack gap="1.5">
                <Icon size="lg">
                  <StickerIcon />
                </Icon>
                <Text size="xs" color="fg.subtle" fontWeight="medium">
                  入典
                </Text>
              </VStack>
              <Text size="lg" fontVariantNumeric="tabular-nums">
                {statistics.threads}
              </Text>
            </VStack>
          </Center>

          <Center>
            <VStack>
              <VStack gap="1.5">
                <Icon size="lg">
                  <UsersRoundIcon />
                </Icon>
                <Text size="xs" color="fg.subtle" fontWeight="medium">
                  关注
                </Text>
              </VStack>
              <Text size="lg" fontVariantNumeric="tabular-nums">
                {statistics.followers}
              </Text>
            </VStack>
          </Center>
        </Grid>
      </Card.Footer>
    </Card.Root>
  )
}

const RssFeedCard = () => {
  return (
    <Card.Root>
      <Card.Header pb="4">
        <Card.Title>RSS Feed</Card.Title>
        <Card.Description>使用你最爱的 RSS 阅览器来追踪用户的每日动态!</Card.Description>
      </Card.Header>
      <Card.Body>
        <Clipboard.Root value="https://example.com">
          <Clipboard.Label asChild>
            <FormLabel>复制你的订阅链接</FormLabel>
          </Clipboard.Label>
          <Clipboard.Control>
            <Clipboard.Input asChild>
              <Input size="sm" />
            </Clipboard.Input>
            <Clipboard.Trigger asChild>
              <IconButton size="sm" variant="solid">
                <Clipboard.Indicator copied={<ClipboardCheckIcon />}>
                  <ClipboardCopyIcon />
                </Clipboard.Indicator>
              </IconButton>
            </Clipboard.Trigger>
          </Clipboard.Control>
        </Clipboard.Root>
      </Card.Body>
    </Card.Root>
  )
}
