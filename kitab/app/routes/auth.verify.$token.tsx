import { getFormProps, getInputProps, useForm } from "@conform-to/react"
import { getZodConstraint, parseWithZod } from "@conform-to/zod"
import {
  type ActionFunctionArgs,
  type LoaderFunctionArgs,
  type MetaFunction,
  redirect
} from "@remix-run/cloudflare"
import { Form, useActionData, useNavigation } from "@remix-run/react"
import { css } from "styled-system/css"
import { Flex, Stack, VStack } from "styled-system/jsx"
import invariant from "tiny-invariant"
import { z } from "zod"
import { FormErrors } from "~/components/form-errors"
import { Button } from "~/components/ui/button"
import { FormLabel } from "~/components/ui/form-label"
import { Heading } from "~/components/ui/heading"
import { Input } from "~/components/ui/input"
import { Text } from "~/components/ui/text"
import { createToast } from "~/lib/toast.server"
import { AuthService } from "~/services/auth-service"

export const meta: MetaFunction = () => {
  return [{ title: "Confirm - LITTLE RED BOOK" }]
}

export const schema = z
  .object({
    password: z
      .string({ required_error: "请输入您的密码" })
      .min(10, "密码长度至少为10")
      .max(72, "密码长度不能超过72"),
    password_confirmation: z.string({ required_error: "请再次确认输入您的密码" })
  })
  .refine((data) => data.password === data.password_confirmation, {
    path: ["password_confirmation"],
    message: "两次输入的密码不一致"
  })

export const action = async ({ request, context, params }: ActionFunctionArgs) => {
  const token = params.token
  invariant(token, "Token is missing in route params.")

  const formData = await request.formData()
  const submission = parseWithZod(formData, { schema })

  if (submission.status !== "success") {
    return submission.reply()
  }

  const service = new AuthService(context.client.httpClient)
  const isConfirmSuccess = await service.confirmRegistration(token, submission.value)

  if (!isConfirmSuccess) {
    const headers = await createToast({
      type: "error",
      title: "注册失败",
      description: "注册链接似乎出问题了，稍后再试试吧"
    })
    return redirect("/auth/signup", { headers })
  }

  const headers = await createToast({
    type: "success",
    title: "注册成功",
    description: "赶紧去登录吧"
  })
  return redirect("/auth/signin", { headers })
}

export const loader = async ({ params, context }: LoaderFunctionArgs) => {
  const token = params.token
  invariant(token, "Token is missing in route params")

  const service = new AuthService(context.client.httpClient)
  const isVerifiedToken = await service.verifyRegistration(token)
  if (!isVerifiedToken) {
    const headers = await createToast({
      type: "error",
      title: "无效链接",
      description: "注册链接已经失效啦，请重新申请注册"
    })
    return redirect("/auth/signup", { headers })
  }

  return { ok: true }
}

export default function Confirm() {
  return (
    <Flex direction="column" justify="center" align="center" minW="sm">
      <Heading as="h1" size="xl">
        欢迎加入
      </Heading>
      <Text color="fg.subtle" mt="2" mb="4">
        请设定您的账号密码以完成注册
      </Text>
      <ConfirmForm />
    </Flex>
  )
}

const ConfirmForm = () => {
  const lastResult = useActionData<typeof action>()
  const [form, fields] = useForm({
    lastResult,
    constraint: getZodConstraint(schema),
    shouldValidate: "onBlur",
    onValidate: ({ formData }) => parseWithZod(formData, { schema })
  })

  const navigation = useNavigation()
  const isSubmitting = navigation.formAction?.startsWith("/auth/verify/") ?? false

  return (
    <Form method="post" {...getFormProps(form)} className={css({ w: "4/5" })}>
      <VStack gap="4">
        <Stack w="full" gap="1.5">
          <FormLabel htmlFor={fields.password.id}>密码</FormLabel>
          <Input
            autoComplete="current-password"
            placeholder="Your Password"
            {...getInputProps(fields.password, { type: "password" })}
          />
          <FormErrors id={fields.password.errorId} errors={fields.password.errors} />
        </Stack>

        <Stack w="full" gap="1.5">
          <FormLabel htmlFor={fields.password_confirmation.id}>确认密码</FormLabel>
          <Input
            autoComplete="current-password"
            placeholder="Your Password Again"
            {...getInputProps(fields.password_confirmation, { type: "password" })}
          />
          <FormErrors
            id={fields.password_confirmation.errorId}
            errors={fields.password_confirmation.errors}
          />
        </Stack>

        <Button type="submit" w="full" disabled={isSubmitting}>
          完成注册
        </Button>
      </VStack>
    </Form>
  )
}
