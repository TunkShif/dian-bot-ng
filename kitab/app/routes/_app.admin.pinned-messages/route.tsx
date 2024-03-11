import { Portal } from "@ark-ui/react"
import { getFormProps, getInputProps, getTextareaProps, useForm } from "@conform-to/react"
import { getZodConstraint, parseWithZod } from "@conform-to/zod"
import {
  type ActionFunctionArgs,
  type LoaderFunctionArgs,
  type MetaFunction,
  json
} from "@remix-run/cloudflare"
import { useActionData, useFetcher, useLoaderData } from "@remix-run/react"
import { createContextState } from "foxact/context-state"
import { PinnedMessageType } from "gql/graphql"
import { PlusCircleIcon, XIcon } from "lucide-react"
import { useEffect } from "react"
import { Box, HStack, Stack } from "styled-system/jsx"
import { stack } from "styled-system/patterns"
import invariant from "tiny-invariant"
import { z } from "zod"
import { FormErrors } from "~/components/form-errors"
import { PINNED_MESSAGES_ICONS, PINNED_MESSAGES_LABELS } from "~/components/shared/pinned-message"
import { Tooltip } from "~/components/shared/tooltip"
import { Avatar } from "~/components/ui/avatar"
import { Button } from "~/components/ui/button"
import * as Dialog from "~/components/ui/dialog"
import { FormLabel } from "~/components/ui/form-label"
import { Heading } from "~/components/ui/heading"
import { Icon } from "~/components/ui/icon"
import { IconButton } from "~/components/ui/icon-button"
import { Input } from "~/components/ui/input"
import * as Popover from "~/components/ui/popover"
import * as RadioGroup from "~/components/ui/radio-group"
import * as Table from "~/components/ui/table"
import { Text } from "~/components/ui/text"
import { Textarea } from "~/components/ui/textarea"
import { createToast } from "~/lib/toast.server"
import { CreatePinnedMessageMutation } from "~/queries/create-pinned-message"
import { DeletePinnedMessageMutation } from "~/queries/delete-pinned-message"
import { PinnedMessagesQuery } from "~/queries/pinned-messages"

export const meta: MetaFunction = () => {
  return [{ title: "Pinned Messages - LITTLE RED BOOK" }]
}

const createMessageSchema = z.object({
  intent: z.literal("create-message"),
  type: z.nativeEnum(PinnedMessageType),
  title: z.string({ required_error: "请输入标题" }).max(20, "标题长度不能超过 20"),
  content: z.string({ required_error: "请输入内容" }).max(100, "内容长度不能超过 100")
})

const deleteMessageSchema = z.object({
  intent: z.literal("delete-message"),
  id: z.string()
})

export const schema = z.union([createMessageSchema, deleteMessageSchema])

export const action = async ({ request, context }: ActionFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const formData = await request.formData()
  const submission = parseWithZod(formData, { schema })

  if (submission.status !== "success") {
    return json({ result: submission.reply() })
  }

  switch (submission.value.intent) {
    case "create-message": {
      const createPinnedMessageResult = await client
        .mutation(CreatePinnedMessageMutation, submission.value)
        .toPromise()

      if (createPinnedMessageResult.data?.createPinnedMessage) {
        const headers = await createToast({
          type: "success",
          title: "创建成功",
          description: "成功发布一条新的公告"
        })
        return json({ result: null }, { headers })
      }

      break
    }
    case "delete-message": {
      const deletePinnedMessageResult = await client
        .mutation(DeletePinnedMessageMutation, submission.value)
        .toPromise()

      if (deletePinnedMessageResult.data?.deletePinnedMessage) {
        const headers = await createToast({
          type: "success",
          title: "删除成功",
          description: "成功删除该条公告"
        })
        return json({ result: null }, { headers })
      }

      break
    }
  }

  const headers = await createToast({
    type: "error",
    title: "出错了",
    description: "不知道哪里出问题了..."
  })

  return json({ result: submission.reply({ formErrors: ["服务器未知错误"] }) }, { headers })
}

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const pinnedMessagesResult = await client.query(PinnedMessagesQuery, { first: 10 }).toPromise()
  invariant(pinnedMessagesResult.data)

  return json({ pinnedMessages: pinnedMessagesResult.data.pinnedMessages.edges })
}

const [CreateActionProvider, useIsDialogOpen, useSetIsDialogOpen] = createContextState(false)

export default function PinnedMessages() {
  return (
    <Stack p="2">
      <HStack justify="space-between">
        <Stack gap="2">
          <Heading as="h3">站内公告管理</Heading>
          <Text color="fg.subtle" size="sm">
            管理本站首页显示的置顶公告
          </Text>
        </Stack>
        <CreateActionProvider>
          <CreatePinnedMessageAction />
        </CreateActionProvider>
      </HStack>

      <PinnedMessageTable />
    </Stack>
  )
}

const PinnedMessageTable = () => {
  const { pinnedMessages } = useLoaderData<typeof loader>()
  return (
    <Box overflowX="auto">
      <Table.Root minW="xl" size="sm" tableLayout="fixed">
        <Table.Head>
          <Table.Row>
            <Table.Header w="14ch">发布者</Table.Header>
            <Table.Header w="22ch">标题</Table.Header>
            <Table.Header>内容</Table.Header>
            <Table.Header w="12ch" textAlign="right">
              操作
            </Table.Header>
          </Table.Row>
        </Table.Head>

        <Table.Body>
          {pinnedMessages.map((pinnedMessage) => {
            const message = pinnedMessage.node
            const operator = message.operator
            const PinnedMessageIcon = PINNED_MESSAGES_ICONS[pinnedMessage.node.type]

            return (
              <Table.Row key={message.id}>
                <Table.Cell overflow="hidden">
                  <HStack>
                    <Avatar
                      size="xs"
                      src={`/avatar/${operator.qid}`}
                      name={operator.name}
                      borderWidth="1"
                    />
                    <Tooltip content={operator.name} positioning={{ placement: "top-start" }}>
                      <Text fontWeight="medium" truncate>
                        {operator.name}
                      </Text>
                    </Tooltip>
                  </HStack>
                </Table.Cell>

                <Table.Cell>
                  <Tooltip content={message.title} positioning={{ placement: "top-start" }}>
                    <Text truncate>
                      <Icon size="sm" mr="1.5">
                        <PinnedMessageIcon />
                      </Icon>
                      {message.title}
                    </Text>
                  </Tooltip>
                </Table.Cell>

                <Table.Cell>
                  <Tooltip content={message.content} positioning={{ placement: "top-start" }}>
                    <Text maxW="36ch" truncate>
                      {message.content}
                    </Text>
                  </Tooltip>
                </Table.Cell>

                <Table.Cell textAlign="right">
                  <DeletePinnedMessageAction messageId={message.id} />
                </Table.Cell>
              </Table.Row>
            )
          })}
        </Table.Body>
      </Table.Root>
    </Box>
  )
}

const DeletePinnedMessageAction = ({ messageId }: { messageId: string }) => {
  const fetcher = useFetcher()

  return (
    <Popover.Root>
      <Popover.Trigger asChild>
        <Button size="sm" variant="link" color="accent.text">
          删除
        </Button>
      </Popover.Trigger>
      <Portal>
        <Popover.Positioner>
          <Popover.Content>
            <Popover.Arrow>
              <Popover.ArrowTip />
            </Popover.Arrow>

            <Stack gap="2">
              <Stack gap="1">
                <Popover.Title>删除公告</Popover.Title>
                <Popover.Description>确定要删除本条公告吗？</Popover.Description>
              </Stack>
              <HStack justify="end">
                <Popover.CloseTrigger asChild>
                  <Button size="2xs" variant="outline" type="button">
                    取消
                  </Button>
                </Popover.CloseTrigger>

                <fetcher.Form method="delete">
                  <input type="hidden" name="intent" value="delete-message" />
                  <Button size="2xs" type="submit" name="id" value={messageId}>
                    删除
                  </Button>
                </fetcher.Form>
              </HStack>
            </Stack>

            <Box position="absolute" top="1" right="1">
              <Popover.CloseTrigger asChild>
                <IconButton aria-label="关闭确认弹窗" variant="ghost" size="xs">
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

const CreatePinnedMessageAction = () => {
  const isOpen = useIsDialogOpen()
  const setIsOpen = useSetIsDialogOpen()

  return (
    <Dialog.Root open={isOpen} onOpenChange={(e) => setIsOpen(e.open)}>
      <Dialog.Trigger asChild>
        <Button flexShrink={0} size="xs">
          <Icon>
            <PlusCircleIcon />
          </Icon>
          发布新公告
        </Button>
      </Dialog.Trigger>

      <Portal>
        <Dialog.Backdrop />
        <Dialog.Positioner>
          <Dialog.Content w="full" minW="xs" maxW="xs" md={{ maxW: "md" }}>
            <Stack p="6" gap="1" borderBottomWidth="1">
              <Dialog.Title>创建新公告</Dialog.Title>
              <Dialog.Description>发布一条新的在站内首页置顶显示的消息</Dialog.Description>
            </Stack>

            <CreatePinnedMessageForm />

            <Dialog.CloseTrigger asChild position="absolute" top="2" right="2">
              <IconButton aria-label="Close Dialog" variant="ghost" size="sm">
                <XIcon />
              </IconButton>
            </Dialog.CloseTrigger>
          </Dialog.Content>
        </Dialog.Positioner>
      </Portal>
    </Dialog.Root>
  )
}

const PINNED_MESSAGE_TYPES = Object.values(PinnedMessageType).map((value) => ({
  label: PINNED_MESSAGES_LABELS[value],
  value
}))

const CreatePinnedMessageForm = () => {
  const actionData = useActionData<typeof action>()
  const [form, fields] = useForm({
    lastResult: actionData?.result,
    constraint: getZodConstraint(createMessageSchema),
    shouldValidate: "onSubmit",
    onValidate: ({ formData }) => parseWithZod(formData, { schema: createMessageSchema })
  })

  const fetcher = useFetcher<typeof action>()
  const isSubmitting = fetcher.state !== "idle"
  const isSubmissionSuccess = fetcher.state === "idle" && fetcher.data?.result === null

  const setIsOpen = useSetIsDialogOpen()

  useEffect(() => {
    if (isSubmissionSuccess) {
      form.reset()
      setIsOpen(false)
    }
  }, [form, setIsOpen, isSubmissionSuccess])

  return (
    <fetcher.Form method="post" {...getFormProps(form)} className={stack({ p: "6" })}>
      <input
        value="create-message"
        {...getInputProps(fields.intent, { type: "hidden", value: false })}
      />

      <Stack gap="4">
        <Stack gap="1.5">
          <FormLabel size="sm" htmlFor={fields.title.id}>
            标题
          </FormLabel>
          <Input size="sm" {...getInputProps(fields.title, { type: "text" })} />
          <FormErrors errors={fields.title.errors} />
        </Stack>

        <Stack gap="1.5">
          <FormLabel size="sm" htmlFor={fields.type.id}>
            类型
          </FormLabel>
          <RadioGroup.Root
            size="sm"
            orientation="horizontal"
            defaultValue={PinnedMessageType.Info}
            {...getInputProps(fields.type, { type: "radio", value: false })}
          >
            {PINNED_MESSAGE_TYPES.map(({ label, value }) => {
              const LabelIcon = PINNED_MESSAGES_ICONS[value]
              return (
                <RadioGroup.Item key={value} value={value}>
                  <RadioGroup.ItemControl />
                  <RadioGroup.ItemText>
                    <Icon size="sm" mr="1">
                      <LabelIcon />
                    </Icon>
                    {label}
                  </RadioGroup.ItemText>
                </RadioGroup.Item>
              )
            })}
          </RadioGroup.Root>
          <FormErrors errors={fields.type.errors} />
        </Stack>

        <Stack gap="1.5">
          <FormLabel size="sm">内容</FormLabel>
          <Textarea size="sm" {...getTextareaProps(fields.content)} />
          <FormErrors errors={fields.content.errors} />
        </Stack>
      </Stack>

      <Stack gap="3" direction="row" width="full">
        <Dialog.CloseTrigger asChild>
          <Button size="sm" variant="outline" width="full" type="button">
            取消
          </Button>
        </Dialog.CloseTrigger>
        <Button size="sm" width="full" type="submit" disabled={isSubmitting}>
          确认
        </Button>
      </Stack>
    </fetcher.Form>
  )
}
