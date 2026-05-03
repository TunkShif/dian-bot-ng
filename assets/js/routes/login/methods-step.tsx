import { EnvelopeSimpleIcon, FingerprintIcon } from "@phosphor-icons/react";
import { useMutation } from "@tanstack/react-query";
import type { SubmitEvent } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";
import { loginUserMutation } from "@/client/@tanstack/react-query.gen";
import { Button } from "@/components/ui/button";
import { Field, FieldDescription, FieldGroup, FieldLabel, FieldSeparator } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { AuthHeader, QQEmailInput } from "@/routes/login/auth-step-fields";

type MethodsStepProps = {
  input: string;
  onInputChange: (value: string) => void;
  onResetEmail: () => void;
};

export const MethodsStep = ({ input, onResetEmail, onInputChange }: MethodsStepProps) => {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const { mutate: loginWithPassword, isPending: isPasswordLoginPending } = useMutation({
    ...loginUserMutation(),
    onSuccess: () => {
      navigate("/dashboard", { replace: true });
    },
    meta: {
      errorTitle: t("auth.login.methodsStep.passwordLogin.errorTitle"),
      errorMessage: t("auth.login.methodsStep.passwordLogin.errorMessage"),
    },
  });

  const { mutate: loginWithoutPassword, isPending: isPasswordlessLoginPending } = useMutation({
    ...loginUserMutation(),
    meta: {
      successTitle: t("auth.login.methodsStep.passwordlessLogin.successTitle"),
      successMessage: t("auth.login.methodsStep.passwordlessLogin.successMessage"),
      errorTitle: t("auth.login.methodsStep.passwordlessLogin.errorTitle"),
      errorMessage: t("auth.login.methodsStep.passwordlessLogin.errorMessage"),
    },
  });

  const isPending = isPasswordLoginPending || isPasswordlessLoginPending;

  const handleSubmit = (event: SubmitEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!input) return;
    const formData = new FormData(event.currentTarget);
    const password = formData.get("password");
    if (!password) return;
    loginWithPassword({
      body: {
        user: {
          email: `${input}@qq.com`,
          password: password.toString(),
          remember_me: "true" as const,
        },
      },
    });
  };

  const handleEmailRequest = () => {
    if (!input) return;
    loginWithoutPassword({
      body: {
        user: {
          email: `${input}@qq.com`,
          remember_me: "true" as const,
        },
      },
    });
  };

  return (
    <form className="p-6 md:p-8" onSubmit={handleSubmit}>
      <FieldGroup>
        <AuthHeader title={t("auth.login.methodsStep.title")} description={t("auth.login.methodsStep.description")} />
        <Field>
          <FieldLabel htmlFor="input">{t("auth.login.fields.email")}</FieldLabel>
          <QQEmailInput id="input" value={input} onChange={onInputChange} readOnly />
        </Field>
        <Field>
          <FieldLabel htmlFor="password">{t("auth.login.fields.password")}</FieldLabel>
          <Input id="password" type="password" name="password" required />
        </Field>

        <Field>
          <Button type="submit" disabled={isPending}>
            {t("auth.login.methodsStep.signIn")}
          </Button>
        </Field>

        <FieldSeparator className="*:data-[slot=field-separator-content]:bg-card">
          {t("auth.login.methodsStep.separator")}
        </FieldSeparator>

        <Field>
          <Button variant="outline" type="button" disabled={isPending} onClick={handleEmailRequest}>
            <EnvelopeSimpleIcon data-icon="inline-start" />
            {t("auth.login.methodsStep.emailLink")}
          </Button>
        </Field>

        <Field>
          <Button variant="outline" type="button" disabled={isPending}>
            <FingerprintIcon data-icon="inline-start" />
            {t("auth.login.methodsStep.passkey")}
          </Button>
        </Field>

        <FieldDescription className="text-center">
          <button
            type="button"
            className="font-medium text-primary underline-offset-4 transition-colors hover:text-primary/80 hover:underline"
            onClick={onResetEmail}
          >
            {t("auth.login.methodsStep.useDifferentEmail")}
          </button>
        </FieldDescription>
      </FieldGroup>
    </form>
  );
};
