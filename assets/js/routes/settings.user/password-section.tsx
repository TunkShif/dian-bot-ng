import { CheckIcon, KeyIcon } from "@phosphor-icons/react";
import { useForm } from "@tanstack/react-form";
import { useMutation } from "@tanstack/react-query";
import { useMemo } from "react";
import { useTranslation } from "react-i18next";
import * as z from "zod";
import { updateUserSettingsMutation } from "@/client/@tanstack/react-query.gen";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Field, FieldDescription, FieldError, FieldGroup, FieldLabel, FieldSet } from "@/components/ui/field";
import { Input } from "@/components/ui/input";

export const PasswordSection = () => {
  const { t } = useTranslation();

  const passwordFormSchema = useMemo(
    () =>
      z
        .object({
          password: z
            .string()
            .min(12, t("app.settings.password.validation.passwordMin"))
            .max(72, t("app.settings.password.validation.passwordMax")),
          passwordConfirmation: z
            .string()
            .min(12, t("app.settings.password.validation.confirmationMin"))
            .max(72, t("app.settings.password.validation.confirmationMax")),
        })
        .refine((value) => value.password === value.passwordConfirmation, {
          message: t("app.settings.password.validation.passwordsMatch"),
          path: ["passwordConfirmation"],
        }),
    [t],
  );

  const { mutate, isPending } = useMutation({
    ...updateUserSettingsMutation(),
    meta: {
      successTitle: t("app.settings.password.update.successTitle"),
      successMessage: t("app.settings.password.update.successMessage"),
      errorMessage: t("app.settings.password.update.errorMessage"),
    },
  });

  const form = useForm({
    defaultValues: {
      password: "",
      passwordConfirmation: "",
    },
    validators: {
      onSubmit: passwordFormSchema,
    },
    onSubmit: ({ value }) => {
      mutate(
        {
          body: {
            user: {
              password: value.password,
              password_confirmation: value.passwordConfirmation,
            },
          },
        },
        {
          onSuccess: () => form.reset(),
        },
      );
    },
  });

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
        <form
          className="max-w-2xl"
          onSubmit={(event) => {
            event.preventDefault();
            form.handleSubmit();
          }}
        >
          <FieldSet>
            <FieldGroup>
              <div className="grid gap-4 sm:grid-cols-2">
                <form.Field name="password">
                  {(field) => {
                    const isInvalid = field.state.meta.isTouched && !field.state.meta.isValid;

                    return (
                      <Field data-invalid={isInvalid}>
                        <FieldLabel htmlFor={field.name}>{t("app.settings.password.newPassword.label")}</FieldLabel>
                        <Input
                          id={field.name}
                          name={field.name}
                          type="password"
                          autoComplete="new-password"
                          minLength={12}
                          maxLength={72}
                          value={field.state.value}
                          onBlur={field.handleBlur}
                          onChange={(event) => field.handleChange(event.target.value)}
                          aria-invalid={isInvalid}
                          disabled={isPending}
                          placeholder={t("app.settings.password.newPassword.placeholder")}
                        />
                        {isInvalid && <FieldError errors={field.state.meta.errors} />}
                      </Field>
                    );
                  }}
                </form.Field>
                <form.Field name="passwordConfirmation">
                  {(field) => {
                    const isInvalid = field.state.meta.isTouched && !field.state.meta.isValid;

                    return (
                      <Field data-invalid={isInvalid}>
                        <FieldLabel htmlFor={field.name}>{t("app.settings.password.confirmPassword.label")}</FieldLabel>
                        <Input
                          id={field.name}
                          name={field.name}
                          type="password"
                          autoComplete="new-password"
                          minLength={12}
                          maxLength={72}
                          value={field.state.value}
                          onBlur={field.handleBlur}
                          onChange={(event) => field.handleChange(event.target.value)}
                          aria-invalid={isInvalid}
                          disabled={isPending}
                          placeholder={t("app.settings.password.confirmPassword.placeholder")}
                        />
                        {isInvalid && <FieldError errors={field.state.meta.errors} />}
                      </Field>
                    );
                  }}
                </form.Field>
              </div>

              <FieldDescription>{t("app.settings.password.helper")}</FieldDescription>

              <div className="flex justify-start">
                <form.Subscribe selector={(state) => [state.canSubmit, state.isSubmitting]}>
                  {([canSubmit, isSubmitting]) => (
                    <Button type="submit" disabled={!canSubmit || isSubmitting || isPending}>
                      <CheckIcon data-icon="inline-start" />
                      {t("app.settings.password.submit")}
                    </Button>
                  )}
                </form.Subscribe>
              </div>
            </FieldGroup>
          </FieldSet>
        </form>
      </CardContent>
    </Card>
  );
};
