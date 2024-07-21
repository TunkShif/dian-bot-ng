import { Portal } from "@ark-ui/react"
import { getFormProps, getInputProps, useForm } from "@conform-to/react"
import { getZodConstraint, parseWithZod } from "@conform-to/zod"
import { graphql } from "gql"
import { XIcon } from "lucide-react"
import { useTranslation } from "react-i18next"
import { type ActionFunctionArgs, Form, Link, useNavigation } from "react-router-dom"
import { css } from "styled-system/css"
import { Box, Flex, HStack, Stack, VStack, styled } from "styled-system/jsx"
import z from "zod"
import { FormErrors } from "~/components/form"
import { SpinnerIcon } from "~/components/icon"
import { toaster } from "~/components/toaster"
import { Button } from "~/components/ui/button"
import { Checkbox } from "~/components/ui/checkbox"
import { Heading } from "~/components/ui/heading"
import { IconButton } from "~/components/ui/icon-button"
import { Input } from "~/components/ui/input"
import { Link as StyledLink } from "~/components/ui/link"
import * as Popover from "~/components/ui/popover"
import { Text } from "~/components/ui/text"
import { i18n } from "~/libs/i18n"
import { client } from "~/libs/urql"

const schema = z.object({
  email: z
    .string({ required_error: i18n.t("auth:validation.required_email") })
    .max(20, i18n.t("auth:validation.invalid_email"))
    .email(i18n.t("auth:validation.invalid_email"))
    .regex(/^\d{6,}@qq\.com$/, i18n.t("auth:validation.invalid_email")),
  agree: z.boolean({ required_error: i18n.t("auth:validation.required_agreement") })
})

const mutation = graphql(`
  mutation CreateUserAccountMutation($email: String!) {
    createUserAccount(email: $email)
  }
`)

export const signUpAction = async ({ request }: ActionFunctionArgs) => {
  const formData = await request.formData()
  const submission = parseWithZod(formData, { schema })
  if (submission.status !== "success") return { ok: false }

  const { data, error } = await client.mutation(mutation, submission.value)
  const code = data?.createUserAccount?.toLowerCase() ?? "registration_requested"
  const failed = error && code !== "registration_requested"

  const title = failed
    ? i18n.t("auth:notification.registration_failed")
    : i18n.t("auth:notification.registration_success")
  const description = error
    ? i18n.t("notification.unknown_error")
    : i18n.t(`auth:notification.${code}`)
  toaster.create({ type: "info", title, description, duration: 1000000 })

  return { ok: true }
}

export const SignUpPage = () => {
  const { t } = useTranslation()

  return (
    <Flex direction="column" justify="center" align="center" minW="sm">
      <Heading as="h1" size="xl">
        {t("auth:create_account.title")}
      </Heading>
      <Text color="fg.subtle" mt="2" mb="4">
        {t("auth:create_account.description")}
      </Text>

      <SignUpForm />

      <HStack w="4/5" my="4">
        <styled.div w="full" borderBlockEndWidth="1px" borderColor="border.subtle" />
        <Text size="sm" color="fg.subtle" flexShrink="0" fontWeight="light">
          {t("auth:sign_in.hint")}
        </Text>
        <styled.div w="full" borderBlockEndWidth="1px" borderColor="border.subtle" />
      </HStack>

      <Button variant="outline" w="4/5" asChild>
        <Link to="/auth/signin">{t("auth:sign_in.label")}</Link>
      </Button>
    </Flex>
  )
}

const SignUpForm = () => {
  const { t } = useTranslation()

  const [form, fields] = useForm({
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
          {isSubmitting && <SpinnerIcon size="sm" />}
          {t("auth:create_account.label")}
        </Button>

        <Stack w="full" gap="1.5">
          <HStack gap="0" alignItems="center">
            <Checkbox size="sm" {...getInputProps(fields.agree, { type: "checkbox" })}>
              {t("auth:user_agreement.label")}
            </Checkbox>
            <AgreementsPopover />
          </HStack>
          <FormErrors id={fields.agree.errorId} errors={fields.agree.errors} />
        </Stack>
      </VStack>
    </Form>
  )
}

const AgreementsPopover = () => {
  const { t } = useTranslation()
  return (
    <Popover.Root>
      <Popover.Trigger asChild>
        <StyledLink display="inline-block" color="accent.text" fontSize="sm" fontWeight="bold">
          {t("auth:user_agreement.name")}
        </StyledLink>
      </Popover.Trigger>
      <Portal>
        <Popover.Positioner>
          <Popover.Content>
            <Popover.Arrow>
              <Popover.ArrowTip />
            </Popover.Arrow>
            <Stack gap="1">
              <Popover.Title>{t("auth:user_agreement.title")}</Popover.Title>
              <Popover.Description>{t("auth:user_agreement.description")}</Popover.Description>
            </Stack>
            <Box position="absolute" top="1" right="1">
              <Popover.CloseTrigger asChild>
                <IconButton
                  aria-label={t("auth:user_agreement.close_trigger")}
                  variant="ghost"
                  size="xs"
                >
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
