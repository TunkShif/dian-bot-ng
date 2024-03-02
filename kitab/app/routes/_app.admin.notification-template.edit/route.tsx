import { getFormProps, getTextareaProps, useForm } from "@conform-to/react"
import { getZodConstraint, parseWithZod } from "@conform-to/zod"
import {
  json,
  redirect,
  type ActionFunctionArgs,
  type LoaderFunctionArgs
} from "@remix-run/cloudflare"
import { Form, Link, useActionData, useLoaderData } from "@remix-run/react"
import { CreateNotificationMessageDocument, type NotificationMessage } from "gql/graphql"
import { ArrowLeftIcon, ChevronDownIcon, SaveIcon } from "lucide-react"
import { css } from "styled-system/css"
import { Box, HStack, Stack } from "styled-system/jsx"
import { z } from "zod"
import { FormErrors } from "~/components/form-errors"
import { Button } from "~/components/ui/button"
import { Code } from "~/components/ui/code"
import * as Collapsible from "~/components/ui/collapsible"
import { FormLabel } from "~/components/ui/form-label"
import { Heading } from "~/components/ui/heading"
import { Icon } from "~/components/ui/icon"
import * as Table from "~/components/ui/table"
import { Text } from "~/components/ui/text"
import { Textarea } from "~/components/ui/textarea"
import { UserNotficationMessageQuery } from "~/queries/user-notification-message"

const schema = z.object({
  template: z
    .string({ required_error: "请输入模板内容" })
    .max(120, { message: "自定义模板内容长度不能超过 120" })
})

export const action = async ({ request, context }: ActionFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const formData = await request.formData()
  const submission = parseWithZod(formData, { schema })

  if (submission.status !== "success") {
    return json({ result: submission.reply() })
  }

  const createNotificationResult = await client
    .mutation(CreateNotificationMessageDocument, submission.value)
    .toPromise()

  if (createNotificationResult.data?.createNotificationMessage) {
    return redirect("/admin/notification-template")
  }

  const isTemplateSyntaxError = createNotificationResult.error?.graphQLErrors.some(
    (error) => error.message === "template invalid syntax"
  )
  if (isTemplateSyntaxError) {
    return { result: submission.reply({ formErrors: ["自定义消息内容含有错误的模板语法"] }) }
  }

  return { result: submission.reply({ formErrors: ["服务器未知错误"] }) }
}

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const userNotificationResult = await client.query(UserNotficationMessageQuery, {}).toPromise()
  const notification = (userNotificationResult.data?.me?.notificationMessage ??
    null) as NotificationMessage | null

  return json({
    notification
  })
}

export default function NotificationTemplateEdit() {
  const actionData = useActionData<typeof action>()
  const { notification } = useLoaderData<typeof loader>()

  const [form, fields] = useForm({
    lastResult: actionData?.result,
    constraint: getZodConstraint(schema),
    shouldValidate: "onSubmit",
    onValidate: ({ formData }) => parseWithZod(formData, { schema })
  })

  return (
    <Stack gap="6">
      <HStack justify="space-between">
        <Stack gap="2">
          <Heading as="h3">通知模板编辑</Heading>
          <Text color="fg.subtle" size="sm">
            设置个人专属的 Bot 入典通知消息模板
          </Text>
        </Stack>
        <HStack flexShrink={0}>
          <Button variant="outline" size="xs" asChild>
            <Link to=".." relative="path">
              <Icon>
                <ArrowLeftIcon />
              </Icon>
              返回
            </Link>
          </Button>

          <Button size="xs" type="submit" form={form.id}>
            <Icon>
              <SaveIcon />
            </Icon>
            保存
          </Button>
        </HStack>
      </HStack>

      <Form method="post" {...getFormProps(form)}>
        <Stack gap="1.5">
          <FormLabel size="sm" htmlFor={fields.template.id}>
            模板内容
          </FormLabel>
          <Textarea
            size="sm"
            defaultValue={notification?.template}
            {...getTextareaProps(fields.template)}
          />
          <FormErrors errors={fields.template.errors} />
          <FormErrors errors={form.errors} />
        </Stack>
      </Form>

      <TemplateHelp />
    </Stack>
  )
}

const TEMPLATE_SYNTAX_DOCS = [
  { name: "at_me", description: "@入典的操作者" },
  { name: "at_user", description: "@消息的发送者" },
  { name: "dian_url", description: "入典后的查看链接" }
]

const TemplateHelp = () => {
  return (
    <Box mx="-6" px="6" pt="4" mb="-2" borderTopWidth="1">
      <Collapsible.Root>
        <Collapsible.Trigger asChild>
          <Button variant="link" size="sm">
            模板语法帮助
            <Icon
              className={css({
                "[data-scope='collapsible'][data-state='open'] &": {
                  rotate: "-180deg"
                }
              })}
            >
              <ChevronDownIcon />
            </Icon>
          </Button>
        </Collapsible.Trigger>
        <Collapsible.Content>
          <Stack>
            <Text size="sm" color="fg.subtle" pt="2">
              使用 <Code size="sm" fontFamily="mono">{`{{}}`}</Code>{" "}
              语法可以在消息中插入特定的显示内容, 目前支持的模板插值变量如下:
            </Text>

            <Box overflowX="auto">
              <Table.Root minW="xl" size="sm" variant="outline">
                <Table.Head>
                  <Table.Row>
                    <Table.Header w="16ch">变量</Table.Header>
                    <Table.Header>内容</Table.Header>
                  </Table.Row>
                </Table.Head>

                <Table.Body>
                  {TEMPLATE_SYNTAX_DOCS.map(({ name, description }) => (
                    <Table.Row key={name}>
                      <Table.Cell>
                        <Code size="sm" fontFamily="mono">{`{{${name}}}`}</Code>
                      </Table.Cell>
                      <Table.Cell>
                        <Text size="xs">{description}</Text>
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table.Body>
              </Table.Root>
            </Box>
          </Stack>
        </Collapsible.Content>
      </Collapsible.Root>
    </Box>
  )
}
