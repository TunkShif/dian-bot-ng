import { NotebookIcon, TranslateIcon } from "@phosphor-icons/react";
import { parseAsStringLiteral, useQueryState } from "nuqs";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { redirect } from "react-router-dom";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useLanguage } from "@/hooks/use-language";
import { getCurrentUser } from "@/lib/user";
import { AuthForm } from "@/routes/login/auth-form";

const authStepParser = parseAsStringLiteral(["email", "methods"] as const).withDefault("email");

export const handle = { pageTitleKey: "auth.login.pageTitle" } as const;

export const loader = async () => {
  const user = await getCurrentUser();
  if (user) {
    return redirect("/dashboard");
  }
  return {};
};

export const Component = () => {
  const { t } = useTranslation();
  const [input, setInput] = useState("");
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
      <LanguageSwitch />
      <div className="relative z-10 w-full max-w-sm md:max-w-4xl">
        <AuthForm
          step={step}
          input={input}
          imageUrl="/images/abstract-wave-pattern-bg.webp"
          imageAlt={t("auth.login.imageAlt")}
          onContinue={() => setStep("methods")}
          onResetEmail={() => {
            setStep("email");
            setInput("");
          }}
          onInputChange={(value) => setInput(value)}
        />
      </div>
    </div>
  );
};

const LanguageSwitch = () => {
  const { t } = useTranslation();
  const { languages, currentLanguage, currentLanguageLabel, changeLanguage } = useLanguage();

  return (
    <div className="absolute right-4 bottom-4 z-20 md:right-8 md:bottom-8">
      <DropdownMenu>
        <DropdownMenuTrigger
          render={
            <Button
              aria-label={t("auth.login.languageSwitch.label")}
              className="h-8 gap-1.5 border-border/70 bg-background/70 px-2.5 text-xs text-muted-foreground shadow-lg shadow-foreground/5 backdrop-blur-md hover:bg-background/90 hover:text-foreground"
              size="sm"
              variant="outline"
            >
              <TranslateIcon className="size-3.5" />
              <span className="max-w-24 truncate">{currentLanguageLabel}</span>
            </Button>
          }
        />
        <DropdownMenuContent align="end" side="top" sideOffset={8} className="min-w-36">
          <DropdownMenuRadioGroup value={currentLanguage} onValueChange={changeLanguage}>
            {languages.map((language) => (
              <DropdownMenuRadioItem key={language.code} value={language.code}>
                {language.label}
              </DropdownMenuRadioItem>
            ))}
          </DropdownMenuRadioGroup>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  );
};

const BrandMark = () => {
  const { t } = useTranslation();

  return (
    <div className="absolute top-5 left-5 z-20 flex items-center gap-2.5 rounded-full border border-border/70 bg-background/80 px-3 py-2 text-foreground shadow-lg shadow-foreground/5 backdrop-blur-md transition-colors md:top-8 md:left-8">
      <div className="flex size-8 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-sm shadow-primary/20">
        <NotebookIcon className="size-4.5" weight="bold" />
      </div>
      <span className="text-sm font-semibold whitespace-nowrap text-foreground/80 uppercase select-none">
        {t("auth.login.brandName")}
      </span>
    </div>
  );
};
