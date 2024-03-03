import { useLoaderData } from "@remix-run/react"
import type { PinnedMessage } from "gql/graphql"
import { VStack } from "styled-system/jsx"
import { PINNED_MESSAGES_ICONS } from "~/components/shared/pinned-message"
import * as Alert from "~/components/ui/alert"
import type { loader as dashboardLoader } from "~/routes/_app.dashboard/route"

export const PinnedMessageList = () => {
  const { pinnedMessages } = useLoaderData<typeof dashboardLoader>()
  return (
    <VStack w="full" _empty={{ display: "none" }}>
      {pinnedMessages.map((pinnedMessage) => (
        <PinnedMessageItem
          key={pinnedMessage.node.id}
          message={pinnedMessage.node as PinnedMessage}
        />
      ))}
    </VStack>
  )
}

const PinnedMessageItem = ({ message }: { message: PinnedMessage }) => {
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
