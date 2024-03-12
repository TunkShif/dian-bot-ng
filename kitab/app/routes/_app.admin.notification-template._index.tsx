import { type LoaderFunctionArgs, type MetaFunction, json } from "@remix-run/cloudflare"
import { Link, useLoaderData } from "@remix-run/react"
import type { NotificationMessage } from "gql/graphql"
import { SquarePenIcon } from "lucide-react"
import { Box, Grid, HStack, Stack } from "styled-system/jsx"
import invariant from "tiny-invariant"
import { Avatar } from "~/components/ui/avatar"
import { Button } from "~/components/ui/button"
import { Heading } from "~/components/ui/heading"
import { Icon } from "~/components/ui/icon"
import { Text } from "~/components/ui/text"
import { NotificationMessagesQuery } from "~/queries/notification-messages"

export const meta: MetaFunction = () => {
  return [{ title: "Notification Template - LITTLE RED BOOK" }]
}

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  // TODO: pagination
  const notificationMessagesResult = await client
    .query(NotificationMessagesQuery, { first: 20 })
    .toPromise()

  invariant(notificationMessagesResult.data)

  return json({ notificationMessages: notificationMessagesResult.data.notificationMessages.edges })
}

export default function NotificationTemplate() {
  return (
    <Stack gap="6">
      <HStack justify="space-between">
        <Stack gap="2">
          <Heading as="h3">通知消息设定</Heading>
          <Text color="fg.subtle" size="sm">
            设置用户专属的 Bot 入典通知消息模板
          </Text>
        </Stack>
        <Button flexShrink={0} size="xs" asChild>
          <Link to="edit">
            <Icon>
              <SquarePenIcon />
            </Icon>
            编辑我的模板
          </Link>
        </Button>
      </HStack>

      <NotificationTemplateBoard />
    </Stack>
  )
}

const NotificationTemplateBoard = () => {
  const { notificationMessages } = useLoaderData<typeof loader>()

  return (
    <Box>
      <Grid
        gap="4"
        columns={1}
        gridAutoRows="1fr"
        md={{ gridTemplateColumns: 2 }}
        lg={{ gridTemplateColumns: 3 }}
      >
        {notificationMessages.map(({ node }) => (
          <NotificationTemplateItem key={node.id} notification={node as NotificationMessage} />
        ))}
      </Grid>
    </Box>
  )
}

// TODO: pagination
// TODO: preview is default badge

const NotificationTemplateItem = ({ notification }: { notification: NotificationMessage }) => {
  const user = notification.operator
  return (
    <Box bg="bg.default" rounded="lg" borderWidth="1" p="4" _hover={{ bg: "bg.subtle" }}>
      <Stack>
        <HStack>
          <Avatar borderWidth="1" src={`/avatar/${user.qid}`} name={user.name} />
          <Text fontWeight="semibold">{user.name}</Text>
        </HStack>
        <Text size="sm" color="fg.subtle" fontWeight="medium" lineHeight="normal" lineClamp={3}>
          {notification.template}
        </Text>
      </Stack>
    </Box>
  )
}
