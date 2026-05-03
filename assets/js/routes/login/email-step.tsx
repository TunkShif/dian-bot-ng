import { EnvelopeSimpleIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
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

  return (
    <form
      className="flex min-h-120 items-center p-6 md:p-8"
      onSubmit={(event) => {
        event.preventDefault();
        onContinue();
      }}
    >
      <FieldGroup className="w-full">
        <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-primary/10 text-primary">
          <EnvelopeSimpleIcon className="size-6" />
        </div>

        <AuthHeader title={t("auth.login.emailStep.title")} description={t("auth.login.emailStep.description")} />

        <Field>
          <FieldLabel htmlFor="email">{t("auth.login.fields.email")}</FieldLabel>
          <QQEmailInput id="email" value={input} onChange={onInputChange} />
        </Field>

        <Field>
          <Button type="submit">{t("auth.login.emailStep.continue")}</Button>
        </Field>

        <div className="rounded-2xl border bg-muted/40 px-4 py-3 text-sm text-muted-foreground">
          {t("auth.login.emailStep.qqHint")}
        </div>

        <FieldDescription className="text-center">
          {t("auth.login.emailStep.noAccount")}{" "}
          <button
            type="button"
            className="font-medium text-primary underline-offset-4 transition-colors hover:text-primary/80 hover:underline"
            onClick={onContinue}
          >
            {t("auth.login.emailStep.signUp")}
          </button>
        </FieldDescription>
      </FieldGroup>
    </form>
  );
};
