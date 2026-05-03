import { EnvelopeSimpleIcon, FingerprintIcon } from "@phosphor-icons/react";
import { useMutation } from "@tanstack/react-query";
import type { SubmitEvent } from "react";
import { useTranslation } from "react-i18next";
import { loginUserMutation } from "@/client/@tanstack/react-query.gen";
import { Button } from "@/components/ui/button";
import { Field, FieldDescription, FieldGroup, FieldLabel, FieldSeparator } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";
import { AuthHeader, QQEmailInput } from "@/routes/login/auth-step-fields";

type MethodsStepProps = {
  input: string;
  onInputChange: (value: string) => void;
  onResetEmail: () => void;
};

export const MethodsStep = ({ input, onResetEmail, onInputChange }: MethodsStepProps) => {
  const { t } = useTranslation();

  // TODO: i18n
  const { mutate, isPending } = useMutation({
    ...loginUserMutation(),
    meta: {
      errorTitle: "登录出错",
      errorMessage: "请检查您的邮箱和密码",
      successMessage: "请查看邮箱中的登录链接",
    },
  });

  const loginUser = (password?: string) => {
    const user = { email: `${input}@qq.com`, password, rember_me: true };
    mutate({
      body: { user },
    });
  };

  const handleSubmit = (event: SubmitEvent<HTMLFormElement>) => {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    const password = formData.get("password");
    if (!password) return;
    loginUser(password.toString());
  };

  const handleEmailRequest = () => loginUser();

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
        <Tooltip>
          <TooltipTrigger>
            <Field>
              <Button variant="outline" type="button" disabled render={<div />} nativeButton={false}>
                <FingerprintIcon data-icon="inline-start" />
                {t("auth.login.methodsStep.passkey")}
              </Button>
            </Field>
          </TooltipTrigger>
          <TooltipContent>计划开发中，暂不可用</TooltipContent>
        </Tooltip>

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
