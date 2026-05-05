import { useTranslation } from "react-i18next";
import { PasskeysSection } from "@/routes/settings.user/passkeys-section";
import { PasswordSection } from "@/routes/settings.user/password-section";

export const handle = { pageTitleKey: "app.settings.pageTitle" } as const;

export const Component = () => {
  const { t } = useTranslation();

  return (
    <main className="mx-auto flex w-full max-w-5xl flex-col gap-6 px-4 lg:px-6">
      <header className="flex flex-col gap-2">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
          <div className="space-y-1">
            <h1 className="font-heading text-2xl font-semibold tracking-normal text-foreground md:text-3xl">
              {t("app.settings.title")}
            </h1>
            <p className="max-w-2xl text-sm text-muted-foreground">{t("app.settings.description")}</p>
          </div>
        </div>
      </header>

      <PasswordSection />
      <PasskeysSection />
    </main>
  );
};
