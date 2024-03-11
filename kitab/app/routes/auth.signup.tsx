import { Portal } from "@ark-ui/react"
import { getFormProps, getInputProps, useForm } from "@conform-to/react"
import { getZodConstraint, parseWithZod } from "@conform-to/zod"
import { type ActionFunctionArgs, type MetaFunction, json } from "@remix-run/cloudflare"
import { Form, Link, useActionData, useNavigation } from "@remix-run/react"
import { XIcon } from "lucide-react"
import { css } from "styled-system/css"
import { Box, Flex, HStack, Stack, VStack, styled } from "styled-system/jsx"
import { z } from "zod"
import { FormErrors } from "~/components/form-errors"
import { Button } from "~/components/ui/button"
import { Checkbox } from "~/components/ui/checkbox"
import { Heading } from "~/components/ui/heading"
import { IconButton } from "~/components/ui/icon-button"
import { Input } from "~/components/ui/input"
import { Link as StyledLink } from "~/components/ui/link"
import * as Popover from "~/components/ui/popover"
import { Text } from "~/components/ui/text"
import { createToast } from "~/lib/toast.server"
import { AuthService } from "~/services/auth-service"

export const meta: MetaFunction = () => {
  return [{ title: "Signup - LITTLE RED BOOK" }]
}

export const schema = z.object({
  email: z
    .string({ required_error: "请输入您的邮箱" })
    .max(20, "请输入正确的邮箱")
    .email("请输入正确的邮箱")
    .regex(/^\d{6,}@qq\.com$/, "请输入数字账号的企鹅邮箱"),
  agree: z.boolean({ required_error: "请勾选同意用户协议" })
})

export const action = async ({ request, context }: ActionFunctionArgs) => {
  const formData = await request.formData()
  const submission = parseWithZod(formData, { schema })

  if (submission.status !== "success") {
    return submission.reply()
  }

  const service = new AuthService(context.client.httpClient)
  const result = await service.requestRegistration(submission.value.email)

  if (result.type === "request_success") {
    const headers = await createToast({
      type: "success",
      title: "申请成功",
      description: "请注意查收您的注册确认邮件"
    })
    return json(submission.reply(), { headers })
  }

  let message = ""
  switch (result.type) {
    case "already_requested":
      message = "刚刚已经申请过了哦，请稍后在试"
      break
    case "already_registered":
    case "unauthorized":
      message = "哎呀，当前用户好像还不能注册"
      break
    case "unknown_error":
      message = "不知道哪里出错了，稍后再试试?"
      break
  }

  const headers = await createToast({ type: "error", title: "申请失败", description: message })
  return json(submission.reply(), { headers })
}

export default function SignUp() {
  return (
    <Flex direction="column" justify="center" align="center" minW="sm">
      <Header />
      <SignUpForm />
      <Divider />
      <SignInButton />
    </Flex>
  )
}

const Header = () => (
  <>
    <Heading as="h1" size="xl">
      创建您的账户
    </Heading>
    <Text color="fg.subtle" mt="2" mb="4">
      请输入您账号对应的邮箱以便创建新账户
    </Text>
  </>
)

const SignUpForm = () => {
  const lastResult = useActionData<typeof action>()
  const [form, fields] = useForm({
    lastResult,
    constraint: getZodConstraint(schema),
    shouldValidate: "onBlur",
    onValidate: ({ formData }) => parseWithZod(formData, { schema })
  })

  const navigation = useNavigation()
  const isSubmitting = navigation.formAction === "/auth/signup"

  return (
    <Form method="post" className={css({ w: "4/5" })} {...getFormProps(form)}>
      <VStack gap="4">
        <Stack w="full" gap="1.5">
          <Input
            placeholder="account@company.com"
            {...getInputProps(fields.email, { type: "email" })}
          />
          <FormErrors id={fields.email.errorId} errors={fields.email.errors} />
        </Stack>
        <Button type="submit" w="full" disabled={isSubmitting}>
          创建账户
        </Button>

        <Stack w="full" gap="1.5">
          <HStack gap="0" alignItems="center">
            <Checkbox size="sm" {...getInputProps(fields.agree, { type: "checkbox" })}>
              我已阅读并同意
            </Checkbox>
            <AgreementsPopover />
          </HStack>
          <FormErrors id={fields.agree.errorId} errors={fields.agree.errors} />
        </Stack>
      </VStack>
    </Form>
  )
}

const AgreementsPopover = () => (
  <Popover.Root>
    <Popover.Trigger asChild>
      <StyledLink display="inline-block" color="accent.text" fontSize="sm" fontWeight="bold">
        《用户协议》
      </StyledLink>
    </Popover.Trigger>
    <Portal>
      <Popover.Positioner>
        <Popover.Content>
          <Popover.Arrow>
            <Popover.ArrowTip />
          </Popover.Arrow>
          <Stack gap="1">
            <Popover.Title>用户注册须知</Popover.Title>
            <Popover.Description>
              本站在用户使用过程中会收集用户使用设备信息、基于IP地址的定位信息，以及仅限于本站注册用户范围内共享的用户使用动态记录。如果你不喜欢可以不用。
            </Popover.Description>
          </Stack>
          <Box position="absolute" top="1" right="1">
            <Popover.CloseTrigger asChild>
              <IconButton aria-label="关闭用户协议内容弹窗" variant="ghost" size="sm">
                <XIcon />
              </IconButton>
            </Popover.CloseTrigger>
          </Box>
        </Popover.Content>
      </Popover.Positioner>
    </Portal>
  </Popover.Root>
)

const Divider = () => (
  <HStack w="4/5" my="4">
    <styled.div w="full" borderBlockEndWidth="1px" borderColor="border.subtle" />
    <Text size="sm" color="fg.subtle" flexShrink="0" fontWeight="light">
      已经拥有本站账户?
    </Text>
    <styled.div w="full" borderBlockEndWidth="1px" borderColor="border.subtle" />
  </HStack>
)

const SignInButton = () => (
  <Button variant="outline" w="4/5" asChild>
    <Link to="/auth/signin">用户登录</Link>
  </Button>
)
