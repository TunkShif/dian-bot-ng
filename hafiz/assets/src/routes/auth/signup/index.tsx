import {
  Anchor,
  Button,
  Checkbox,
  Divider,
  Popover,
  Stack,
  Text,
  TextInput,
  Title
} from "@mantine/core"
import { useForm } from "@mantine/form"
import { graphql } from "gql"
import { valibotResolver } from "mantine-form-valibot-resolver"
import { useMemo } from "react"
import { useTranslation } from "react-i18next"
import { Link } from "react-router-dom"
import { useMutation } from "urql"
import { email, literal, maxLength, object, pipe, regex, string } from "valibot"

const mutation = graphql(`
  mutation CreateUserAccountMutation($email: String!) {
    createUserAccount(email: $email)
  }
`)

export const SignUpPage = () => {
  const { t } = useTranslation("auth")

  const schema = useMemo(
    () =>
      object({
        email: pipe(
          string(t("sign_up.form.email.required")),
          maxLength(20, t("sign_up.form.email.invalid")),
          email(t("sign_up.form.email.invalid")),
          regex(/^\d{6,}@qq\.com$/, t("sign_up.form.email.invalid"))
        ),
        agree: literal(true, t("sign_up.form.agree.required"))
      }),
    [t]
  )

  const form = useForm({
    mode: "uncontrolled",
    validateInputOnBlur: true,
    validate: valibotResolver(schema)
  })

  const [{ fetching }, createAccount] = useMutation(mutation)

  const handleSubmit = form.onSubmit(console.log)

  return (
    <Stack>
      <Title order={2} ta="center">
        {t("sign_up.title")}
      </Title>
      <Text c="dimmed" ta="center">
        {t("sign_up.description")}
      </Text>

      <form method="post" onSubmit={handleSubmit}>
        <Stack>
          <TextInput
            key={form.key("email")}
            type="email"
            placeholder={t("sign_up.form.email.placeholder")}
            {...form.getInputProps("email")}
          />

          <Button type="submit">{t("sign_up.form.submit.label")}</Button>

          <Checkbox
            key={form.key("agree")}
            label={
              <div>
                <span style={{ verticalAlign: "middle" }}>{t("sign_up.form.agree.label")}</span>
                <Popover withArrow width={320}>
                  <Popover.Target>
                    <Anchor
                      size="sm"
                      fw={500}
                      component="button"
                      type="button"
                      style={{ verticalAlign: "middle" }}
                    >
                      {t("sign_up.form.agree.name")}
                    </Anchor>
                  </Popover.Target>
                  <Popover.Dropdown>
                    <Title order={3} size="h5">
                      {t("sign_up.form.agree.title")}
                    </Title>
                    <Text size="sm" c="dimmed">
                      {t("sign_up.form.agree.content")}
                    </Text>
                  </Popover.Dropdown>
                </Popover>
              </div>
            }
            {...form.getInputProps("agree", { type: "checkbox" })}
          />
        </Stack>
      </form>

      <Divider label={t("sign_up.sign_in_hint")} />

      <Button component={Link} variant="default" to="/auth/signin">
        {t("sign_up.sign_in_label")}
      </Button>
    </Stack>
  )
}
