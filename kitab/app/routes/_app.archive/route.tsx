import {
  json,
  type LoaderFunctionArgs,
  type MetaFunction,
  type SerializeFrom
} from "@remix-run/cloudflare"
import { useLoaderData } from "@remix-run/react"
import { graphql } from "gql"
import { AccessibilityIcon } from "lucide-react"
import { Center, Flex, HStack, VStack } from "styled-system/jsx"
import invariant from "tiny-invariant"
import * as Alert from "~/components/ui/alert"
import { Avatar } from "~/components/ui/avatar"
import * as Card from "~/components/ui/card"
import { Text } from "~/components/ui/text"

export const meta: MetaFunction = () => {
  return [{ title: "Archive - LITTLE RED BOOK" }]
}

const ListThreadsQuery = graphql(`
  query ListThreadsQuery {
    threads {
      group {
        gid
        id
        name
      }
      id
      messages {
        content {
          ... on AtMessageContent {
            name
            qid
          }
          ... on ImageMessageContent {
            url
          }
          ... on TextMessageContent {
            text
          }
        }
        id
        sender {
          id
          name
          qid
        }
        sentAt
      }
      owner {
        id
        name
        qid
      }
      postedAt
    }
  }
`)

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)
  const { data } = await client.query(ListThreadsQuery, {}).toPromise()
  invariant(data) // TODO: error handling
  return json({ threads: data.threads })
}

export default function Archive() {
  return (
    <Center>
      <VStack w="lg" my="8" gap="8">
        <Alert.Root>
          <Alert.Icon asChild>
            <AccessibilityIcon />
          </Alert.Icon>
          <Alert.Content>
            <Alert.Title>开发预览页面</Alert.Title>
            <Alert.Description>实在等不及那先凑合用</Alert.Description>
          </Alert.Content>
        </Alert.Root>
        <ThreadList />
      </VStack>
    </Center>
  )
}

const ThreadList = () => {
  const { threads } = useLoaderData<typeof loader>()

  return (
    <VStack maxW="lg" gap="6">
      {threads.map((thread) => (
        <ThreadItem key={thread.id} thread={thread} />
      ))}
    </VStack>
  )
}

type Thread = SerializeFrom<typeof loader>["threads"][number]
type MessageContent = Exclude<Thread["messages"][number], null>["content"][number]

type ThreadItemProps = {
  thread: Thread
}

const ThreadItem = ({ thread }: ThreadItemProps) => {
  return (
    <Card.Root w="lg" shadow="sm">
      <Card.Header>
        <Card.Title>{thread.group.name}</Card.Title>
      </Card.Header>
      <Card.Body>
        <VStack>
          {thread.messages.map((message) => (
            <HStack key={message?.id} w="full" alignItems="start">
              <Avatar
                src={`/avatar/${message?.sender.qid}`}
                name={message?.sender.name}
                size="lg"
                borderWidth="1"
              />
              <Flex direction="column" gap="2">
                <Text>{message?.sender.name}</Text>
                <VStack rounded="lg" bg="bg.subtle" p="2" alignItems="start">
                  {message?.content.map((content, index) => (
                    <MessageContentView key={content.__typename! + index} content={content} />
                  ))}
                </VStack>
              </Flex>
            </HStack>
          ))}
        </VStack>
      </Card.Body>
    </Card.Root>
  )
}

const MessageContentView = ({ content }: { content: MessageContent }) => {
  if (!content.__typename) return null
  switch (content.__typename) {
    case "AtMessageContent":
      return <Text>@{content.name}</Text>
    case "ImageMessageContent":
      return <img src={content.url} loading="lazy" />
    case "TextMessageContent":
      return <Text>{content.text}</Text>
  }
}

// TODO: finish this
// const QuoteView = () => {
//   return null
// }
//
// const ChatsView = () => {
//   return null
// }
