import { Portal } from "@ark-ui/react"
import {
  getFormProps,
  getInputProps,
  getSelectProps,
  getTextareaProps,
  useForm
} from "@conform-to/react"
import { getZodConstraint, parseWithZod } from "@conform-to/zod"
import { Form, useActionData, useFetcher, useLoaderData, useNavigation } from "@remix-run/react"
import { PinnedMessageType } from "gql/graphql"
import { CheckIcon, ChevronsUpDownIcon, PlusCircleIcon, XIcon } from "lucide-react"
import { omit } from "radash"
import { createElement } from "react"
import { Flex, HStack, Stack } from "styled-system/jsx"
import { stack } from "styled-system/patterns"
import { z } from "zod"
import { FormErrors } from "~/components/form-errors"
import { PINNED_MESSAGES_ICONS, PINNED_MESSAGES_LABELS } from "~/components/shared/pinned-message"
import { Tooltip } from "~/components/shared/tooltip"
import { Button } from "~/components/ui/button"
import * as Card from "~/components/ui/card"
import * as Dialog from "~/components/ui/dialog"
import { FormLabel } from "~/components/ui/form-label"
import { Heading } from "~/components/ui/heading"
import { Icon } from "~/components/ui/icon"
import { IconButton } from "~/components/ui/icon-button"
import { Input } from "~/components/ui/input"
import * as Select from "~/components/ui/select"
import * as Table from "~/components/ui/table"
import { Text } from "~/components/ui/text"
import { Textarea } from "~/components/ui/textarea"
import type { loader as broadcastLoader, action } from "~/routes/_app.admin.broadcast/route"

export const schema = z.object({
  intent: z.literal("create-pinned-message"),
  type: z.nativeEnum(PinnedMessageType),
  title: z.string({ required_error: "请输入标题" }).max(20, "标题长度不能超过 20"),
  content: z.string({ required_error: "请输入内容" }).max(100, "内容长度不能超过 100")
})

export const SitePinnedMessage = () => {
  return (
    <Stack w="full">
      <Stack>
        <Heading size="lg" as="h2">
          站内公告管理
        </Heading>
        <Text color="fg.subtle">管理本站首页显示的置顶公告</Text>
      </Stack>
      <Card.Root>
        <Card.Body pt="6" gap="2">
          <Flex w="full" justifyContent="space-between" alignItems="center">
            <Heading color="fg.subtle" size="sm" as="h3">
              公告列表
            </Heading>
            <CreatePinnedMessage />
          </Flex>
          <PinnedMessageTable />
        </Card.Body>
      </Card.Root>
    </Stack>
  )
}

const PinnedMessageTable = () => {
  const { pinnedMessages } = useLoaderData<typeof broadcastLoader>()
  return (
    <Table.Root size="sm">
      <Table.Head>
        <Table.Row>
          <Table.Header w="10ch">类型</Table.Header>
          <Table.Header w="22ch">标题</Table.Header>
          <Table.Header>内容</Table.Header>
          <Table.Header w="12ch" textAlign="right">
            操作
          </Table.Header>
        </Table.Row>
      </Table.Head>
      <Table.Body>
        {pinnedMessages.map((pinnedMessage) => {
          const PinnedMessageIcon = PINNED_MESSAGES_ICONS[pinnedMessage.node.type]
          return (
            <Table.Row key={pinnedMessage.node.id}>
              <Table.Cell fontWeight="medium">
                <HStack>
                  <Icon size="sm">
                    <PinnedMessageIcon />
                  </Icon>
                  {PINNED_MESSAGES_LABELS[pinnedMessage.node.type]}
                </HStack>
              </Table.Cell>
              <Table.Cell>
                <Tooltip
                  content={pinnedMessage.node.title}
                  positioning={{ placement: "top-start" }}
                >
                  <Text maxW="22ch" truncate>
                    {pinnedMessage.node.title}
                  </Text>
                </Tooltip>
              </Table.Cell>
              <Table.Cell>
                <Tooltip
                  content={pinnedMessage.node.content}
                  positioning={{ placement: "top-start" }}
                >
                  <Text maxW="36ch" truncate>
                    {pinnedMessage.node.content}
                  </Text>
                </Tooltip>
              </Table.Cell>
              <Table.Cell textAlign="right">
                <Button size="sm" variant="link" color="accent.text">
                  删除
                </Button>
              </Table.Cell>
            </Table.Row>
          )
        })}
      </Table.Body>
    </Table.Root>
  )
}

const CreatePinnedMessage = () => {
  return (
    <Dialog.Root>
      <Dialog.Trigger asChild>
        <Button size="xs">
          <Icon>
            <PlusCircleIcon />
          </Icon>
          新公告
        </Button>
      </Dialog.Trigger>

      <Portal>
        <Dialog.Backdrop />
        <Dialog.Positioner>
          <Dialog.Content>
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

const CreatePinnedMessageForm = () => {
  const lastResult = useActionData<typeof action>()
  const [form, fields] = useForm({
    lastResult,
    constraint: getZodConstraint(schema),
    shouldValidate: "onBlur",
    onValidate: ({ formData }) => parseWithZod(formData, { schema })
  })

  const fetcher = useFetcher()
  const isSubmitting = fetcher.state !== "idle"

  return (
    <fetcher.Form
      method="post"
      preventScrollReset
      {...getFormProps(form)}
      className={stack({ px: "6", pt: "2", pb: "6", gap: "6" })}
    >
      <input
        value="create-pinned-message"
        {...getInputProps(fields.intent, { type: "hidden", value: false })}
      />

      <Stack>
        <Stack gap="1.5">
          <HStack gap="6">
            <Stack gap="1.5">
              <FormLabel size="sm" htmlFor={fields.title.id}>
                标题
              </FormLabel>
              <Input size="sm" {...getInputProps(fields.title, { type: "text" })} />
            </Stack>

            <TypeSelect
              {...omit(getSelectProps(fields.type, { value: false }), ["defaultValue"])}
            />
          </HStack>

          <FormErrors errors={fields.title.errors} />
          <FormErrors errors={fields.type.errors} />
        </Stack>

        <Stack gap="1.5">
          <FormLabel flexShrink="0" size="sm">
            内容
          </FormLabel>
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

const PINNED_MESSAGE_TYPES = Object.values(PinnedMessageType).map((value) => ({
  label: PINNED_MESSAGES_LABELS[value],
  value
}))

const TypeSelect = (props: Omit<Select.RootProps, "items" | "children">) => {
  return (
    <Select.Root
      className={stack()}
      defaultValue={["INFO"]}
      w="44"
      size="sm"
      positioning={{ sameWidth: true }}
      items={PINNED_MESSAGE_TYPES}
      {...props}
    >
      <Select.Label flexShrink="0">类型</Select.Label>
      <Select.Control>
        <Select.Trigger>
          <Select.ValueText placeholder="选择消息类型" />
          <ChevronsUpDownIcon />
        </Select.Trigger>
      </Select.Control>
      <Select.Positioner>
        <Select.Content>
          {PINNED_MESSAGE_TYPES.map((type) => (
            <Select.Item key={type.value} item={type}>
              <Select.ItemText>
                <Icon size="sm" mr="1.5">
                  {createElement(PINNED_MESSAGES_ICONS[type.value], {})}
                </Icon>
                {type.label}
              </Select.ItemText>
              <Select.ItemIndicator>
                <CheckIcon />
              </Select.ItemIndicator>
            </Select.Item>
          ))}
        </Select.Content>
      </Select.Positioner>
    </Select.Root>
  )
}
