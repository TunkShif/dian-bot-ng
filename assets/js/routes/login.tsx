import { EnvelopeSimpleIcon, FingerprintIcon } from "@phosphor-icons/react";
import { parseAsStringLiteral, useQueryState } from "nuqs";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Field, FieldDescription, FieldGroup, FieldLabel, FieldSeparator } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { InputGroup, InputGroupAddon, InputGroupInput, InputGroupText } from "@/components/ui/input-group";

const authStepParser = parseAsStringLiteral(["email", "methods"] as const).withDefault("email");

export const Component = () => {
  const [step, setStep] = useQueryState("step", authStepParser);

  return (
    <div className="flex min-h-svh flex-col items-center justify-center bg-muted p-6 md:p-10">
      <div className="w-full max-w-sm md:max-w-4xl">
        <AuthForm step={step} onContinue={() => setStep("methods")} onResetEmail={() => setStep("email")} />
      </div>
    </div>
  );
};

type AuthFormProps = {
  step: "email" | "methods";
  onContinue: () => void;
  onResetEmail: () => void;
};

const AuthForm = ({ step, onContinue, onResetEmail }: AuthFormProps) => {
  return (
    <div className="flex flex-col gap-6">
      <Card className="overflow-hidden p-0 shadow-xl shadow-foreground/5">
        <CardContent className="grid min-h-120 p-0 md:grid-cols-2">
          {step === "email" ? <EmailStep onContinue={onContinue} /> : <MethodsStep onResetEmail={onResetEmail} />}
          <div className="relative hidden bg-muted md:block">
            <img
              src="/images/abstract-wave-pattern-bg.webp"
              alt="placeholder for now"
              className="absolute inset-0 h-full w-full object-cover dark:brightness-[0.2] dark:grayscale"
            />
          </div>
        </CardContent>
      </Card>
      <FieldDescription className="px-6 text-center">
        By clicking continue, you agree to our <a href="/terms">Terms of Service</a> and{" "}
        <a href="/privacy">Privacy Policy</a>.
      </FieldDescription>
    </div>
  );
};

const EmailStep = ({ onContinue }: { onContinue: () => void }) => {
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
        <AuthHeader title="Welcome" description="Enter your QQ email to continue." />
        <Field>
          <FieldLabel htmlFor="email">Email</FieldLabel>
          <QQEmailInput id="email" />
        </Field>
        <Field>
          <Button type="submit">Continue</Button>
        </Field>
        <div className="rounded-2xl border bg-muted/40 px-4 py-3 text-sm text-muted-foreground">
          Enter your QQ number only. We&apos;ll add @qq.com and show your available sign-in options next.
        </div>
        <FieldDescription className="text-center">
          No account yet? Click here to{" "}
          <button
            type="button"
            className="font-medium text-primary underline-offset-4 transition-colors hover:text-primary/80 hover:underline"
            onClick={onContinue}
          >
            Sign up
          </button>
        </FieldDescription>
      </FieldGroup>
    </form>
  );
};

const MethodsStep = ({ onResetEmail }: { onResetEmail: () => void }) => {
  return (
    <form className="p-6 md:p-8">
      <FieldGroup>
        <AuthHeader title="Welcome" description="Choose how you want to continue." />
        <Field>
          <FieldLabel htmlFor="email">Email</FieldLabel>
          <QQEmailInput id="email" readOnly />
        </Field>
        <Field>
          <FieldLabel htmlFor="password">Password</FieldLabel>
          <Input id="password" type="password" required />
        </Field>
        <Field>
          <Button type="submit">Sign in</Button>
        </Field>
        <FieldSeparator className="*:data-[slot=field-separator-content]:bg-card">Or</FieldSeparator>
        <Field>
          <Button variant="outline" type="button">
            <EnvelopeSimpleIcon data-icon="inline-start" />
            Send email link
          </Button>
        </Field>
        <Field>
          <Button variant="outline" type="button">
            <FingerprintIcon data-icon="inline-start" />
            Sign in with passkey
          </Button>
        </Field>
        <FieldDescription className="text-center">
          <button
            type="button"
            className="font-medium text-primary underline-offset-4 transition-colors hover:text-primary/80 hover:underline"
            onClick={onResetEmail}
          >
            Use a different email
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
  return (
    <InputGroup>
      <InputGroupInput
        id={id}
        type="text"
        inputMode="numeric"
        pattern="\d{5,13}"
        minLength={5}
        maxLength={13}
        placeholder="123456789"
        title="Enter 5 to 13 digits"
        required
        readOnly={readOnly}
      />
      <InputGroupAddon align="inline-end">
        <InputGroupText>@qq.com</InputGroupText>
      </InputGroupAddon>
    </InputGroup>
  );
};
