import { parseWithZod } from "@conform-to/zod"
import { createId as cuid2 } from "@paralleldrive/cuid2"
import {
  type ActionFunctionArgs,
  type LoaderFunctionArgs,
  type MetaFunction,
  json
} from "@remix-run/cloudflare"
import { useLoaderData } from "@remix-run/react"
import { atom, getDefaultStore, useAtom, useAtomValue } from "jotai"
import { atomWithImmer } from "jotai-immer"
import { BotIcon, CheckCircleIcon, CircleXIcon, ForwardIcon, LoaderCircleIcon } from "lucide-react"
import { Fragment, type KeyboardEvent, useCallback, useState } from "react"
import { Box, Center, Flex, HStack, Stack } from "styled-system/jsx"
import { hstack, stack } from "styled-system/patterns"
import invariant from "tiny-invariant"
import { z } from "zod"
import { Tooltip } from "~/components/shared/tooltip"
import { Avatar } from "~/components/ui/avatar"
import { Heading } from "~/components/ui/heading"
import { Icon } from "~/components/ui/icon"
import { IconButton } from "~/components/ui/icon-button"
import { Text } from "~/components/ui/text"
import { Textarea } from "~/components/ui/textarea"
import { CreateBroadcastMessageMutation } from "~/queries/create-broadcast-message"
import { GroupsQuery } from "~/queries/groups"

export const meta: MetaFunction = () => {
  return [{ title: "Broadcast Message - LITTLE RED BOOK" }]
}

export const schema = z.object({
  groupId: z.string(),
  message: z.string().min(1).max(200)
})

export const action = async ({ request, context }: ActionFunctionArgs) => {
  const formData = await request.formData()
  const submission = parseWithZod(formData, { schema })

  if (submission.status !== "success")
    return json({
      success: false
    })

  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)
  const result = await client.mutation(CreateBroadcastMessageMutation, submission.value).toPromise()

  return json({
    success: result.data?.createBroadcastMessage ?? false
  })
}

export const useBroadcastLoaderData = () => useLoaderData<typeof loader>()

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  // TODO: pagination later
  const groupsResult = await client.query(GroupsQuery, { first: 20 }).toPromise()
  invariant(groupsResult.data)

  return json({
    groups: groupsResult.data.groups.edges
  })
}

export default function MessageBroadcast() {
  return (
    <Stack p="2">
      <Stack gap="2">
        <Heading as="h3">群内消息广播</Heading>
        <Text color="fg.subtle" size="sm">
          通过 Bot 账号向用户群内发布公告消息
        </Text>
      </Stack>

      <BroadcastSection />
    </Stack>
  )
}

type GroupID = string
type MessageID = string

type Message = {
  id: GroupID
  content: string
  status: MessageStatus
  timestamp: number
}

type MessageStatus = "submitting" | "sent" | "error"

type GroupMessage = Record<GroupID, Record<MessageID, Message>>

const store = getDefaultStore()
const groupMessageAtom = atomWithImmer<GroupMessage>({})
const currentGroupAtom = atom<GroupID>("")
const currentMessagesAtom = atom<Message[]>((get) => {
  const currentGroup = get(currentGroupAtom)
  const groupMessages = get(groupMessageAtom)
  const currentMessages = groupMessages[currentGroup] ?? {}
  return Object.values(currentMessages).sort((a, b) => a.timestamp - b.timestamp)
})

const createBroadcastMessage = async (id: string, params: z.infer<typeof schema>) => {
  store.set(groupMessageAtom, (draft) => {
    if (!draft[params.groupId]) draft[params.groupId] = {}

    draft[params.groupId][id] = {
      id,
      content: params.message,
      status: "submitting",
      timestamp: Date.now()
    }
  })

  const formData = new FormData()
  for (const [key, value] of Object.entries(params)) {
    formData.append(key, value)
  }

  let success = false
  try {
    const response = await fetch(
      `/admin/message-broadcast?_data=${encodeURIComponent("routes/_app.admin.message-broadcast")}`,
      { method: "POST", body: formData }
    )
    const result = await response.json<{ success: boolean }>()
    if (result.success) success = true
  } catch (e) {}

  store.set(groupMessageAtom, (draft) => {
    draft[params.groupId][id].status = success ? "sent" : "error"
  })
}

const BroadcastSection = () => {
  return (
    <Box bg="bg.canvas" rounded="sm" borderWidth="1">
      <Flex>
        <Box flex="1" borderRightWidth="1">
          <GroupList />
        </Box>

        <Stack flex="4">
          <ChatBox />
        </Stack>
      </Flex>
    </Box>
  )
}

const GroupList = () => {
  const { groups } = useBroadcastLoaderData()
  const [currentGroup, setCurrentGroup] = useAtom(currentGroupAtom)

  return (
    <Stack gap="0">
      <Heading
        display="flex"
        alignItems="center"
        h="12"
        px="4"
        bg="bg.default"
        size="sm"
        fontWeight="semibold"
        borderBottomWidth="1"
        as="h4"
      >
        用户群组列表
      </Heading>

      <Box p="2" overflowY="auto">
        <ul className={stack({ gap: "1.5", h: "60vh" })}>
          {groups.map((group) => (
            <li key={group.node.gid}>
              <Tooltip content={group.node.name} positioning={{ placement: "right" }}>
                <button
                  type="button"
                  data-active={currentGroup === group.node.gid ? true : undefined}
                  onClick={() => setCurrentGroup(group.node.gid)}
                  className={hstack({
                    w: "full",
                    gap: "2",
                    p: "2",
                    rounded: "md",
                    cursor: "pointer",
                    transition: "colors {durations.fast} ease-in-out",
                    _hover: { bg: "gray.4" },
                    _active: { bg: "gray.5" }
                  })}
                >
                  <Avatar src={`/avatar/${group.node.gid}?type=group`} name={group.node.name} />

                  <Stack gap="0.5" justifyContent="start">
                    <Text size="sm" fontWeight="medium" textAlign="start" lineClamp={1}>
                      {group.node.name}
                    </Text>
                    <Text size="sm" color="fg.subtle" textAlign="start" lineClamp={1}>
                      ({group.node.gid})
                    </Text>
                  </Stack>
                </button>
              </Tooltip>
            </li>
          ))}
        </ul>
      </Box>
    </Stack>
  )
}

const ChatBox = () => {
  return (
    <Box w="full" h="full" position="relative">
      <MessageList />
      <InputBox />
    </Box>
  )
}

const MessageList = () => {
  const messages = useAtomValue(currentMessagesAtom)

  return (
    <Box p="2" w="full">
      <ul
        className={stack({
          p: "2",
          gap: "4",
          maxH: "calc(60vh + {spacing.10})",
          overflowY: "auto"
        })}
      >
        {messages.map((message) => (
          <li key={message.id}>
            <HStack gap="2" alignItems="start">
              <Center w="10" h="10" bg="accent.4" rounded="full">
                <Icon size="sm" color="accent.emphasized">
                  <BotIcon />
                </Icon>
              </Center>
              <Box bg="bg.emphasized" p="2" rounded="md">
                {message.content.split("\n").map((text, index) => (
                  // biome-ignore lint/suspicious/noArrayIndexKey: no other key
                  <Fragment key={index}>
                    {text}
                    <br />
                  </Fragment>
                ))}
              </Box>
              <MessageStatusIndicator status={message.status} />
            </HStack>
          </li>
        ))}
      </ul>
    </Box>
  )
}

const MessageStatusIndicator = ({ status }: { status: MessageStatus }) => {
  switch (status) {
    case "submitting":
      return (
        <Box alignSelf="end">
          <Icon size="xs" color="fg.default" animation="spin 1s linear infinite">
            <LoaderCircleIcon />
          </Icon>
        </Box>
      )
    case "sent":
      return (
        <Box alignSelf="end">
          <Icon size="xs" color="grass.9">
            <CheckCircleIcon />
          </Icon>
        </Box>
      )
    case "error":
      return (
        <Box alignSelf="end">
          <Icon size="xs" color="tomato.9">
            <CircleXIcon />
          </Icon>
        </Box>
      )
  }
}

const InputBox = () => {
  const [content, setContent] = useState("")

  const currentGroup = useAtomValue(currentGroupAtom)

  const handleSubmit = useCallback(() => {
    const id = cuid2()
    const params = {
      groupId: currentGroup,
      message: content
    }
    setContent("")
    createBroadcastMessage(id, params)
  }, [content, currentGroup])

  const handleKeydown = useCallback(
    (e: KeyboardEvent<HTMLTextAreaElement>) => {
      if (e.ctrlKey && e.key === "Enter") {
        e.preventDefault()
        handleSubmit()
      }
    },
    [handleSubmit]
  )

  if (currentGroup === "") return null

  return (
    <Box position="absolute" mx="auto" w="2/3" bottom="4" insetX="0">
      <Box w="full" position="relative">
        <Textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
          onSubmit={handleSubmit}
          onKeyDown={handleKeydown}
          minLength={1}
          maxLength={200}
          required
          resize="none"
          w="full"
          bg="bg.default"
          rounded="xl"
        />

        <Tooltip content="发送" positioning={{ placement: "top" }}>
          <IconButton onClick={handleSubmit} size="xs" position="absolute" right="2" bottom="4">
            <ForwardIcon />
          </IconButton>
        </Tooltip>
      </Box>
    </Box>
  )
}
