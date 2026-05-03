import { Trans } from "react-i18next";
import { Card, CardContent } from "@/components/ui/card";
import { FieldDescription } from "@/components/ui/field";
import { EmailStep } from "@/routes/login/email-step";
import { MethodsStep } from "@/routes/login/methods-step";

type AuthFormProps = {
  step: "email" | "methods";
  input: string;
  imageUrl: string;
  imageAlt: string;
  onContinue: () => void;
  onResetEmail: () => void;
  onInputChange: (value: string) => void;
};

export const AuthForm = ({
  step,
  input,
  imageUrl,
  imageAlt,
  onContinue,
  onResetEmail,
  onInputChange,
}: AuthFormProps) => {
  return (
    <div className="flex flex-col gap-6">
      <Card className="overflow-hidden p-0 shadow-xl shadow-foreground/5">
        <CardContent className="grid min-h-120 p-0 md:grid-cols-2">
          {step === "email" ? (
            <EmailStep input={input} onInputChange={onInputChange} onContinue={onContinue} />
          ) : (
            <MethodsStep input={input} onResetEmail={onResetEmail} onInputChange={onInputChange} />
          )}
          <div className="relative hidden bg-muted md:block">
            <img
              src={imageUrl}
              alt={imageAlt}
              className="absolute inset-0 h-full w-full object-cover dark:brightness-[0.6]"
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
