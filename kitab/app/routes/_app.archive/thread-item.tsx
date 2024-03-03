import type { Message, MessageContent, Thread } from "gql/graphql"
import { Box, Flex, VStack, styled } from "styled-system/jsx"
import { Avatar } from "~/components/ui/avatar"
import * as Card from "~/components/ui/card"
import { Link as StyledLink } from "~/components/ui/link"
import { Text } from "~/components/ui/text"
import { formatDateTime } from "~/lib/helpers"

type ThreadItemProps = {
  thread: Thread
}

export const ThreadItem = ({ thread }: ThreadItemProps) => {
  return (
    <Card.Root w="full" minW="sm">
      <Card.Body px="4" pt="6">
        <VStack w="full">
          {thread.messages.map((message) => (
            <MessageItem key={message.id} message={message} />
          ))}
        </VStack>
      </Card.Body>

      <Card.Footer justifyContent="space-between" px="4" pb="4">
        <Text size="xs" color="fg.subtle">
          来自群
          <StyledLink
            px="0.5"
            maxW="6ch"
            md={{ maxW: "none" }}
            title={thread.group.name}
            truncate
            asChild
          >
            <span>{thread.group.name}</span>
          </StyledLink>
        </Text>
        <Text size="xs" color="fg.subtle">
          由
          <StyledLink
            px="0.5"
            maxW="6ch"
            md={{ maxW: "none" }}
            title={thread.owner.name}
            truncate
            asChild
          >
            <span>{thread.owner.name}</span>
          </StyledLink>
          于<styled.time px="0.5">{formatDateTime(thread.postedAt)}</styled.time>设置
        </Text>
      </Card.Footer>
    </Card.Root>
  )
}

type MessageItemProps = {
  message: Message
}

const MessageItem = ({ message }: MessageItemProps) => {
  return (
    <Flex w="full" gap="2">
      <Box>
        <Avatar src={`/avatar/${message.sender.qid}`} name={message.sender.name} borderWidth="1" />
      </Box>
      <Flex direction="column" gap="1.5">
        <Text size="sm" color="fg.subtle" fontWeight="medium">
          {message.sender.name}
        </Text>
        <Box p="2" bg="bg.emphasized" rounded="md">
          {message.content.map((content, index) => (
            <MessageContentView key={`${message.id}-${index}`} content={content} />
          ))}
        </Box>
      </Flex>
    </Flex>
  )
}

const MessageContentView = ({ content }: { content: MessageContent }) => {
  switch (content.__typename) {
    case "AtMessageContent":
      return (
        <StyledLink asChild>
          <span>@{content.name}</span>
        </StyledLink>
      )
    case "ImageMessageContent":
      return <styled.img rounded="sm" src={content.url} alt="a chat image" loading="lazy" />
    case "TextMessageContent":
      return (
        <>
          {content.text.split("\n").map((it, index) => (
            <Text key={index} wordBreak="break-word">
              {it}
            </Text>
          ))}
        </>
      )
  }
}
