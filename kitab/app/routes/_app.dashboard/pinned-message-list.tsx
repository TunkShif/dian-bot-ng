import { Await, useLoaderData } from "@remix-run/react"
import type { PinnedMessage } from "gql/graphql"
import { InfoIcon } from "lucide-react"
import { Suspense } from "react"
import { Stack, VStack } from "styled-system/jsx"
import { PINNED_MESSAGES_ICONS } from "~/components/shared/pinned-message"
import * as Alert from "~/components/ui/alert"
import { Skeleton } from "~/components/ui/skeleton"
import type { loader as dashboardLoader } from "~/routes/_app.dashboard/route"

export const PinnedMessageList = () => {
  const { pinnedMessagesQuery } = useLoaderData<typeof dashboardLoader>()
  return (
    <VStack w="full" _empty={{ display: "none" }}>
      <Suspense fallback={<PinnedMessageSkeleton />}>
        <Await resolve={pinnedMessagesQuery}>
          {(pinnedMessages) =>
            pinnedMessages.data?.pinnedMessages.edges.map((pinnedMessage) => (
              <PinnedMessageItem
                key={pinnedMessage.node.id}
                message={pinnedMessage.node as PinnedMessage}
              />
            ))
          }
        </Await>
      </Suspense>
    </VStack>
  )
}

const PinnedMessageSkeleton = () => {
  return (
    <Alert.Root>
      <Alert.Icon asChild>
        <InfoIcon />
      </Alert.Icon>
      <Alert.Content>
        <Alert.Title>
          <Skeleton h="2" w="22ch" rounded="full" />
        </Alert.Title>
        <Alert.Description>
          <Stack gap="1">
            <Skeleton h="2" w="48ch" rounded="full" />
            <Skeleton h="2" w="50ch" rounded="full" />
          </Stack>
        </Alert.Description>
      </Alert.Content>
    </Alert.Root>
  )
}

type PinnedMessageItemProps = {
  message: PinnedMessage
}

const PinnedMessageItem = ({ message }: PinnedMessageItemProps) => {
  const PinnedMessageIcon = PINNED_MESSAGES_ICONS[message.type]
  return (
    <Alert.Root>
      <Alert.Icon asChild>
        <PinnedMessageIcon />
      </Alert.Icon>
      <Alert.Content>
        <Alert.Title>{message.title}</Alert.Title>
        <Alert.Description>{message.content}</Alert.Description>
      </Alert.Content>
    </Alert.Root>
  )
}
