import { CheckIcon, KeyIcon } from "@phosphor-icons/react";
import { type FormEvent, useId } from "react";
import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Field, FieldDescription, FieldGroup, FieldLabel, FieldSet } from "@/components/ui/field";
import { Input } from "@/components/ui/input";

export const PasswordSection = () => {
  const { t } = useTranslation();
  const newPasswordId = useId();
  const confirmPasswordId = useId();

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
  };

  return (
    <Card>
      <CardHeader>
        <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
          <KeyIcon className="size-5" weight="duotone" />
        </div>
        <CardTitle>{t("app.settings.password.title")}</CardTitle>
        <CardDescription>{t("app.settings.password.description")}</CardDescription>
      </CardHeader>
      <CardContent>
        <form className="max-w-2xl" onSubmit={handleSubmit}>
          <FieldSet>
            <FieldGroup>
              <div className="grid gap-4 sm:grid-cols-2">
                <Field>
                  <FieldLabel htmlFor={newPasswordId}>{t("app.settings.password.newPassword.label")}</FieldLabel>
                  <Input
                    id={newPasswordId}
                    name="password"
                    type="password"
                    autoComplete="new-password"
                    minLength={12}
                    placeholder={t("app.settings.password.newPassword.placeholder")}
                  />
                </Field>
                <Field>
                  <FieldLabel htmlFor={confirmPasswordId}>
                    {t("app.settings.password.confirmPassword.label")}
                  </FieldLabel>
                  <Input
                    id={confirmPasswordId}
                    name="password_confirmation"
                    type="password"
                    autoComplete="new-password"
                    minLength={12}
                    placeholder={t("app.settings.password.confirmPassword.placeholder")}
                  />
                </Field>
              </div>
              <FieldDescription>{t("app.settings.password.helper")}</FieldDescription>
              <div className="flex justify-start">
                <Button type="submit">
                  <CheckIcon data-icon="inline-start" />
                  {t("app.settings.password.submit")}
                </Button>
              </div>
            </FieldGroup>
          </FieldSet>
        </form>
      </CardContent>
    </Card>
  );
};
