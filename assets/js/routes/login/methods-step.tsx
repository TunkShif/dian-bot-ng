import { EnvelopeSimpleIcon, FingerprintIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
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

  return (
    <form className="p-6 md:p-8">
      <FieldGroup>
        <AuthHeader title={t("auth.login.methodsStep.title")} description={t("auth.login.methodsStep.description")} />
        <Field>
          <FieldLabel htmlFor="email">{t("auth.login.fields.email")}</FieldLabel>
          <QQEmailInput id="email" value={input} onChange={onInputChange} readOnly />
        </Field>
        <Field>
          <FieldLabel htmlFor="password">{t("auth.login.fields.password")}</FieldLabel>
          <Input id="password" type="password" required />
        </Field>
        <Field>
          <Button type="submit">{t("auth.login.methodsStep.signIn")}</Button>
        </Field>
        <FieldSeparator className="*:data-[slot=field-separator-content]:bg-card">
          {t("auth.login.methodsStep.separator")}
        </FieldSeparator>
        <Field>
          <Button variant="outline" type="button">
            <EnvelopeSimpleIcon data-icon="inline-start" />
            {t("auth.login.methodsStep.emailLink")}
          </Button>
        </Field>
        <Field>
          <Button variant="outline" type="button">
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
