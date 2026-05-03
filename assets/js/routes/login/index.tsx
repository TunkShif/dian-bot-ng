import { EnvelopeSimpleIcon, FingerprintIcon, NotebookIcon } from "@phosphor-icons/react";
import { parseAsStringLiteral, useQueryState } from "nuqs";
import { Trans, useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Field, FieldDescription, FieldGroup, FieldLabel, FieldSeparator } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { InputGroup, InputGroupAddon, InputGroupInput, InputGroupText } from "@/components/ui/input-group";

const authStepParser = parseAsStringLiteral(["email", "methods"] as const).withDefault("email");

export const Component = () => {
  const { t } = useTranslation();
  const [step, setStep] = useQueryState("step", authStepParser);

  return (
    <div className="relative isolate flex min-h-svh flex-col items-center justify-center overflow-hidden bg-muted p-6 md:p-10">
      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_50%_35%,color-mix(in_oklch,var(--primary)_12%,transparent),transparent_58%),radial-gradient(ellipse_at_50%_100%,color-mix(in_oklch,var(--foreground)_6%,transparent),transparent_52%)]"
      />
      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-0 opacity-[0.24] bg-[linear-gradient(to_right,color-mix(in_oklch,var(--foreground)_10%,transparent)_1px,transparent_1px),linear-gradient(to_bottom,color-mix(in_oklch,var(--foreground)_10%,transparent)_1px,transparent_1px)] bg-size-[44px_44px]"
      />
      <BrandMark />
      <div className="relative z-10 w-full max-w-sm md:max-w-4xl">
        <AuthForm
          step={step}
          imageAlt={t("auth.login.imageAlt")}
          onContinue={() => setStep("methods")}
          onResetEmail={() => setStep("email")}
        />
      </div>
    </div>
  );
};

const BrandMark = () => {
  return (
    <div className="absolute top-5 left-5 z-20 flex items-center gap-2.5 rounded-full border border-border/70 bg-background/80 px-3 py-2 text-foreground shadow-lg shadow-foreground/5 backdrop-blur-md transition-colors md:top-8 md:left-8">
      <div className="flex size-8 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-sm shadow-primary/20">
        <NotebookIcon className="size-4.5" weight="bold" />
      </div>
      <span className="text-[0.68rem] font-semibold tracking-[0.18em] whitespace-nowrap text-foreground/80 uppercase select-none">
        MY LITTLE RED BOOK
      </span>
    </div>
  );
};

type AuthFormProps = {
  step: "email" | "methods";
  imageAlt: string;
  onContinue: () => void;
  onResetEmail: () => void;
};

const AuthForm = ({ step, imageAlt, onContinue, onResetEmail }: AuthFormProps) => {
  return (
    <div className="flex flex-col gap-6">
      <Card className="overflow-hidden p-0 shadow-xl shadow-foreground/5">
        <CardContent className="grid min-h-120 p-0 md:grid-cols-2">
          {step === "email" ? <EmailStep onContinue={onContinue} /> : <MethodsStep onResetEmail={onResetEmail} />}
          <div className="relative hidden bg-muted md:block">
            <img
              src="/images/abstract-wave-pattern-bg.webp"
              alt={imageAlt}
              className="absolute inset-0 h-full w-full object-cover dark:brightness-[0.2] dark:grayscale"
            />
          </div>
        </CardContent>
      </Card>
      <FieldDescription className="px-6 text-center">
        <Trans
          i18nKey="auth.login.legal.agreement"
          defaults="By clicking continue, you agree to our <terms>Terms of Service</terms> and <privacy>Privacy Policy</privacy>."
          components={{
            terms: <a href="/terms" />,
            privacy: <a href="/privacy" />,
          }}
        />
      </FieldDescription>
    </div>
  );
};

const EmailStep = ({ onContinue }: { onContinue: () => void }) => {
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
          <QQEmailInput id="email" />
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

const MethodsStep = ({ onResetEmail }: { onResetEmail: () => void }) => {
  const { t } = useTranslation();

  return (
    <form className="p-6 md:p-8">
      <FieldGroup>
        <AuthHeader title={t("auth.login.methodsStep.title")} description={t("auth.login.methodsStep.description")} />
        <Field>
          <FieldLabel htmlFor="email">{t("auth.login.fields.email")}</FieldLabel>
          <QQEmailInput id="email" readOnly />
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

const AuthHeader = ({ title, description }: { title: string; description: string }) => {
  return (
    <div className="flex flex-col items-center gap-2 text-center">
      <h1 className="text-2xl font-bold">{title}</h1>
      <p className="text-balance text-muted-foreground">{description}</p>
    </div>
  );
};

const QQEmailInput = ({ id, readOnly }: { id: string; readOnly?: boolean }) => {
  const { t } = useTranslation();

  return (
    <InputGroup>
      <InputGroupInput
        id={id}
        type="text"
        inputMode="numeric"
        pattern="\d{5,13}"
        minLength={5}
        maxLength={13}
        placeholder={t("auth.login.emailInput.placeholder")}
        title={t("auth.login.emailInput.title")}
        required
        readOnly={readOnly}
      />
      <InputGroupAddon align="inline-end">
        <InputGroupText>{t("auth.login.emailInput.domain")}</InputGroupText>
      </InputGroupAddon>
    </InputGroup>
  );
};
