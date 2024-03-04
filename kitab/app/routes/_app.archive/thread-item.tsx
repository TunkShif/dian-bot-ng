import type { ImageMessageContent, Message, MessageContent, Thread } from "gql/graphql"
import { Fragment } from "react/jsx-runtime"
import { css } from "styled-system/css"
import { Box, Flex, Stack, VStack, styled } from "styled-system/jsx"
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

      <Box>
        <Stack gap="1.5">
          <Text size="sm" color="fg.subtle" fontWeight="medium">
            {message.sender.name}
          </Text>
          <Box
            p="2"
            bg="bg.emphasized"
            rounded="md"
            className={css({ "&:has([data-image]:only-child)": { p: "0" } })}
          >
            {message.content.map((content, index) => (
              <MessageContentView key={`${message.id}-${index}`} content={content} />
            ))}
          </Box>
        </Stack>
      </Box>
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
      return <BlurrableImage image={content} />
    case "TextMessageContent": {
      const texts = content.text.split("\n")
      return texts.map((it, index) => (
        <Fragment key={index}>
          <Text wordBreak="break-word" as="span">
            {it}
          </Text>
          {index !== texts.length - 1 && <br />}
        </Fragment>
      ))
    }
  }
}

const BlurrableImage = ({ image }: { image: ImageMessageContent }) => {
  const isOldFormat = image.format === "old"

  if (isOldFormat) {
    return (
      <styled.img rounded="sm" borderWidth="1" src={image.url} alt="a chat image" loading="lazy" />
    )
  }

  return (
    <Box
      data-image
      position="relative"
      maxW="2xs"
      md={{ maxW: "md" }}
      lg={{ maxW: "xs" }}
      w="full"
      h="full"
      rounded="md"
      borderWidth="1"
      overflow="hidden"
      style={{
        aspectRatio: `${image.width!} / ${image.height}`
      }}
    >
      <styled.img
        position="absolute"
        width="full"
        height="full"
        objectFit="cover"
        filter="auto"
        blur="lg"
        scale="auto"
        scaleX="1.1"
        scaleY="1.1"
        src={image.blurredUrl!}
        aria-hidden="true"
      />
      <img
        src={image.url}
        width={image.width!}
        height={image.height!}
        className={css({ position: "relative", maxHeight: "full" })}
      />
    </Box>
  )
}
