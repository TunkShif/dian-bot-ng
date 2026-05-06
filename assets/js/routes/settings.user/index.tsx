import { useTranslation } from "react-i18next";
import { PasskeysSection } from "@/routes/settings.user/passkeys-section";
import { PasswordSection } from "@/routes/settings.user/password-section";
import { SteamSection } from "@/routes/settings.user/steam-section";

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

      <section className="space-y-4">
        <div className="space-y-1">
          <h2 className="font-heading text-lg font-semibold tracking-normal text-foreground">
            {t("app.settings.sections.connectedAccounts.title")}
          </h2>
          <p className="text-sm text-muted-foreground">{t("app.settings.sections.connectedAccounts.description")}</p>
        </div>
        <SteamSection />
      </section>

      <section className="space-y-4">
        <div className="space-y-1">
          <h2 className="font-heading text-lg font-semibold tracking-normal text-foreground">
            {t("app.settings.sections.accountSecurity.title")}
          </h2>
          <p className="text-sm text-muted-foreground">{t("app.settings.sections.accountSecurity.description")}</p>
        </div>
        <PasswordSection />
        <PasskeysSection />
      </section>
    </main>
  );
};
