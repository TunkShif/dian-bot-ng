import { Anchor, Button, PasswordInput, Stack, TextInput, Title } from "@mantine/core"
import { useForm } from "@mantine/form"
import { valibotResolver } from "mantine-form-valibot-resolver"
import { useMemo } from "react"
import { useTranslation } from "react-i18next"
import { Link } from "react-router-dom"
import { maxLength, minLength, object, pipe, regex, string } from "valibot"

export const SignInPage = () => {
  const { t } = useTranslation("auth")

  const schema = useMemo(
    () =>
      object({
        qid: pipe(
          string(t("sign_in.form.qid.required")),
          minLength(5, t("sign_in.form.qid.invalid")),
          maxLength(12, t("sign_in.form.qid.invalid")),
          regex(/^\d{6,}$/, t("sign_in.form.qid.invalid"))
        ),
        password: string(t("sign_in.form.password.required"))
      }),
    [t]
  )

  const form = useForm({
    name: "sign-in",
    mode: "uncontrolled",
    validateInputOnBlur: true,
    validate: valibotResolver(schema)
  })

  return (
    <Stack>
      <Title order={2} ta="center">
        {t("sign_in.title")}
      </Title>

      <form method="post">
        <Stack>
          <TextInput
            key={form.key("qid")}
            label={t("sign_in.form.qid.label")}
            placeholder={t("sign_in.form.qid.placeholder")}
            {...form.getInputProps("qid")}
          />
          <PasswordInput
            key={form.key("password")}
            label={t("sign_in.form.password.label")}
            placeholder={t("sign_in.form.password.placeholder")}
            {...form.getInputProps("password")}
          />
          <Button type="submit" disabled={!form.isValid()} fullWidth>
            {t("sign_in.form.submit.label")}
          </Button>
        </Stack>
      </form>

      <Anchor component={Link} c="dark" size="sm" fw={500} to="/auth/signup">
        {t("sign_in.sign_up_hint")}
      </Anchor>
    </Stack>
  )
}
