import { EnvelopeSimpleIcon } from "@phosphor-icons/react";
import { useMutation } from "@tanstack/react-query";
import { useTranslation } from "react-i18next";
import { registerUserMutation } from "@/client/@tanstack/react-query.gen";
import { Button } from "@/components/ui/button";
import { Field, FieldDescription, FieldGroup, FieldLabel } from "@/components/ui/field";
import { AuthHeader, QQEmailInput } from "@/routes/login/auth-step-fields";

type EmailStepProps = {
  input: string;
  onContinue: () => void;
  onInputChange: (value: string) => void;
};

export const EmailStep = ({ input, onContinue, onInputChange }: EmailStepProps) => {
  const { t } = useTranslation();

  const { mutate, isPending } = useMutation({
    ...registerUserMutation(),
    meta: {
      errorMessage: t("auth.login.emailStep.registration.errorMessage"),
      successTitle: t("auth.login.emailStep.registration.successTitle"),
      successMessage: t("auth.login.emailStep.registration.successMessage"),
    },
  });

  const handleSubmit = (event: React.SubmitEvent<HTMLFormElement>) => {
    event.preventDefault();
    const formData = new FormData(event.currentTarget, event.nativeEvent.submitter);
    const intent = formData.get("intent");

    if (intent === "continue") {
      return onContinue();
    }
    if (intent === "signup") {
      const email = `${input}@qq.com`;
      mutate({
        body: {
          user: { email },
        },
      });
    }
  };

  return (
    <form id="email-form" className="flex min-h-120 items-center p-6 md:p-8" onSubmit={handleSubmit}>
      <FieldGroup className="w-full">
        <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-primary/10 text-primary">
          <EnvelopeSimpleIcon className="size-6" />
        </div>

        <AuthHeader title={t("auth.login.emailStep.title")} description={t("auth.login.emailStep.description")} />

        <Field>
          <FieldLabel htmlFor="email-input">{t("auth.login.fields.email")}</FieldLabel>
          <QQEmailInput id="email-input" value={input} onChange={onInputChange} />
        </Field>

        <Field>
          <Button type="submit" name="intent" value="continue" disabled={isPending}>
            {t("auth.login.emailStep.continue")}
          </Button>
        </Field>

        <div className="rounded-2xl border bg-muted/40 px-4 py-3 text-sm text-muted-foreground">
          {t("auth.login.emailStep.qqHint")}
        </div>

        <FieldDescription className="text-center">
          {t("auth.login.emailStep.noAccount")}{" "}
          <button
            type="submit"
            name="intent"
            value="signup"
            disabled={isPending}
            className="font-medium text-primary underline-offset-4 transition-colors hover:text-primary/80 hover:underline"
          >
            {t("auth.login.emailStep.signUp")}
          </button>
        </FieldDescription>
      </FieldGroup>
    </form>
  );
};
