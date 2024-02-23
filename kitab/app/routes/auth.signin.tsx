import { getFormProps, getInputProps, useForm } from "@conform-to/react"
import { getZodConstraint, parseWithZod } from "@conform-to/zod"
import { json, redirect, type ActionFunctionArgs, type MetaFunction } from "@remix-run/cloudflare"
import { Form, Link, useActionData, useNavigation } from "@remix-run/react"
import { css } from "styled-system/css"
import { Flex, Stack, VStack } from "styled-system/jsx"
import { z } from "zod"
import { FormErrors } from "~/components/form-errors"
import { Button } from "~/components/ui/button"
import { FormLabel } from "~/components/ui/form-label"
import { Heading } from "~/components/ui/heading"
import { Input } from "~/components/ui/input"
import { Link as StyledLink } from "~/components/ui/link"
import { combineHeaders } from "~/lib/helpers"
import { createToast } from "~/lib/toast.server"
import { AuthService } from "~/services/auth-service"

export const meta: MetaFunction = () => {
  return [{ title: "Signin - LITTLE RED BOOK" }]
}

export const schema = z.object({
  qid: z
    .string({ required_error: "请输入你的企鹅账号" })
    .min(5, "请输入正确的账号")
    .max(12, "请输入正确的账号")
    .regex(/^\d{6,}$/, "请输入正确的账号"),
  password: z.string({ required_error: "请输入你的本站密码" })
})

export const action = async ({ request, context }: ActionFunctionArgs) => {
  const sessionStorage = context.sessionStorage
  const formData = await request.formData()
  const submission = parseWithZod(formData, { schema })

  if (submission.status !== "success") {
    return submission.reply()
  }

  const device = request.headers.get("User-Agent")
  const location = null // TODO: get user request IP

  const service = new AuthService(context.env.HAFIZ_API_URL)
  const result = await service.signIn({ ...submission.value, device, location })

  if (result.type === "signin_success") {
    const session = await sessionStorage.getSession(request)
    session.set("token", result.token)

    const setUserToken = await sessionStorage.commitSession(session)
    const sendSuccessToast = await createToast({
      type: "success",
      title: "登录成功",
      description: "欢迎回来~"
    })

    const headers = combineHeaders(setUserToken, sendSuccessToast)
    return redirect("/dashboard", { headers })
  }

  if (result.type === "unauthorized") {
    const headers = await createToast({
      type: "error",
      title: "登录失败",
      description: "账号密码好像不对..."
    })
    return json(submission.reply({ formErrors: ["账号密码好像不对..."] }), { headers })
  }

  const headers = await createToast({
    type: "error",
    title: "登录失败",
    description: "不知道哪里出错了，稍后再试试?"
  })
  return json(submission.reply({ formErrors: ["不知道哪里出错了，稍后再试试?"] }), { headers })
}

export default function SignUp() {
  return (
    <Flex direction="column" justify="center" align="center" minW="sm">
      <Heading as="h1" size="xl" mb="4">
        👋 Welcome back!
      </Heading>
      <SignInForm />
    </Flex>
  )
}

const SignInForm = () => {
  const lastResult = useActionData<typeof action>()
  const [form, fields] = useForm({
    lastResult,
    constraint: getZodConstraint(schema),
    shouldValidate: "onBlur",
    onValidate: ({ formData }) => parseWithZod(formData, { schema })
  })

  const navigation = useNavigation()
  const isSubmitting = navigation.formAction === "/auth/signin"

  return (
    <Form method="post" {...getFormProps(form)} className={css({ w: "4/5" })}>
      <VStack gap="4">
        <Stack w="full" gap="1.5">
          <FormLabel htmlFor={fields.qid.id}>账号</FormLabel>
          <Input placeholder="Your QQ Number" {...getInputProps(fields.qid, { type: "text" })} />
          <FormErrors id={fields.qid.errorId} errors={fields.qid.errors} />
        </Stack>
        <Stack w="full" gap="1.5">
          <FormLabel htmlFor={fields.password.id}>密码</FormLabel>
          <Input
            autoComplete="current-password"
            placeholder="Not Your QQ Password"
            {...getInputProps(fields.password, { type: "password" })}
          />
          <FormErrors id={fields.password.errorId} errors={fields.password.errors} />
        </Stack>
        <Button type="submit" w="full" disabled={isSubmitting}>
          登录
        </Button>
        <StyledLink w="full" textAlign="right" fontSize="sm" asChild>
          <Link to="/auth/signup">还没有本站账户?</Link>
        </StyledLink>
      </VStack>
    </Form>
  )
}
