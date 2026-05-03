import { EnvelopeSimpleIcon, FingerprintIcon } from "@phosphor-icons/react";
import { parseAsStringLiteral, useQueryState } from "nuqs";
import type { ComponentProps } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Field, FieldDescription, FieldGroup, FieldLabel, FieldSeparator } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { InputGroup, InputGroupAddon, InputGroupInput, InputGroupText } from "@/components/ui/input-group";
import { cn } from "@/lib/utils";

const authFormParser = parseAsStringLiteral(["login", "register"] as const).withDefault("login");

export const Component = () => {
  const [selectedForm, setSelectedForm] = useQueryState("form", authFormParser);

  return (
    <div className="flex min-h-svh flex-col items-center justify-center bg-muted p-6 md:p-10">
      <div className="w-full max-w-sm md:max-w-4xl">
        <div className="relative min-h-167.5 overflow-visible md:min-h-147.5">
          <div
            aria-hidden={selectedForm !== "login"}
            className={cn(
              "absolute inset-0 transition-all duration-300 ease-out",
              selectedForm === "login"
                ? "translate-y-0 scale-100 opacity-100 blur-0"
                : "-translate-y-2 scale-[0.98] opacity-0 blur-[2px] pointer-events-none",
            )}
          >
            <LoginForm onSelectRegister={() => setSelectedForm("register")} />
          </div>
          <div
            aria-hidden={selectedForm !== "register"}
            className={cn(
              "absolute inset-0 transition-all duration-300 ease-out",
              selectedForm === "register"
                ? "translate-y-0 scale-100 opacity-100 blur-0"
                : "translate-y-2 scale-[0.98] opacity-0 blur-[2px] pointer-events-none",
            )}
          >
            <RegisterForm onSelectLogin={() => setSelectedForm("login")} />
          </div>
        </div>
      </div>
    </div>
  );
};

type AuthFormProps = ComponentProps<"div">;

type LoginFormProps = AuthFormProps & {
  onSelectRegister: () => void;
};

type RegisterFormProps = AuthFormProps & {
  onSelectLogin: () => void;
};

const LoginForm = ({ className, onSelectRegister, ...props }: LoginFormProps) => {
  return (
    <div className={cn("flex flex-col gap-6", className)} {...props}>
      <Card className="overflow-hidden p-0">
        <CardContent className="grid p-0 md:grid-cols-2">
          <form className="p-6 md:p-8">
            <FieldGroup>
              <div className="flex flex-col items-center gap-2 text-center">
                <h1 className="text-2xl font-bold">Welcome back</h1>
                <p className="text-balance text-muted-foreground">Login to you little red book account.</p>
              </div>
              <Field>
                <FieldLabel htmlFor="email">Email</FieldLabel>
                <QQEmailInput id="email" />
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
                  Sign in via email link
                </Button>
              </Field>
              <Field>
                <Button variant="outline" type="button">
                  <FingerprintIcon data-icon="inline-start" />
                  Sign in with passkey
                </Button>
              </Field>
              <FieldDescription className="text-center">
                Don&apos;t have an account?{" "}
                <button
                  type="button"
                  className="font-medium text-primary underline-offset-4 transition-colors hover:text-primary/80 hover:underline"
                  onClick={onSelectRegister}
                >
                  Sign up
                </button>
              </FieldDescription>
            </FieldGroup>
          </form>
          <div className="relative hidden bg-muted md:block">
            <img
              src="/images/abstract-wave-pattern-bg.webp"
              alt="warm gradient abstract wave pattern background"
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

const RegisterForm = ({ className, onSelectLogin, ...props }: RegisterFormProps) => {
  return (
    <div className={cn("flex flex-col gap-6", className)} {...props}>
      <Card className="overflow-hidden p-0">
        <CardContent className="grid min-h-105 p-0 md:grid-cols-2">
          <form className="p-6 md:p-8">
            <FieldGroup>
              <div className="flex flex-col items-center gap-2 text-center">
                <h1 className="text-2xl font-bold">Create an account</h1>
                <p className="text-balance text-muted-foreground">Enter your email to get started.</p>
              </div>
              <Field>
                <FieldLabel htmlFor="register-email">Email</FieldLabel>
                <QQEmailInput id="register-email" />
              </Field>
              <Field>
                <Button type="submit">
                  <EnvelopeSimpleIcon data-icon="inline-start" />
                  Send sign up link
                </Button>
              </Field>
              <FieldDescription className="text-center">
                Already have an account?{" "}
                <button
                  type="button"
                  className="font-medium text-primary underline-offset-4 transition-colors hover:text-primary/80 hover:underline"
                  onClick={onSelectLogin}
                >
                  Sign in
                </button>
              </FieldDescription>
            </FieldGroup>
          </form>
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

const QQEmailInput = ({ id }: { id: string }) => {
  return (
    <InputGroup>
      <InputGroupInput id={id} type="text" inputMode="numeric" placeholder="123456789" required />
      <InputGroupAddon align="inline-end">
        <InputGroupText>@qq.com</InputGroupText>
      </InputGroupAddon>
    </InputGroup>
  );
};
