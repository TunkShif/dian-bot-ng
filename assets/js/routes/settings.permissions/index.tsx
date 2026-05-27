import { ShieldCheckIcon, CrownIcon, UserIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

export const handle = { pageTitleKey: "app.settings.permissions.pageTitle" } as const;

export const Component = () => {
  const { t } = useTranslation();

  return (
    <main className="mx-auto flex w-full max-w-5xl flex-col gap-6 px-4 lg:px-6">
      <header className="flex flex-col gap-2">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
          <div className="space-y-1">
            <h1 className="font-heading text-2xl font-semibold tracking-normal text-foreground md:text-3xl">
              {t("app.settings.permissions.title")}
            </h1>
            <p className="max-w-2xl text-sm text-muted-foreground">
              {t("app.settings.permissions.description")}
            </p>
          </div>
        </div>
      </header>

      <section className="space-y-4">
        <div className="rounded-xl border border-border/70 bg-muted/30 p-6">
          <div className="flex items-start gap-4">
            <div className="flex size-12 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <ShieldCheckIcon className="size-6" weight="duotone" />
            </div>
            <div className="space-y-2">
              <h3 className="font-heading text-lg font-semibold text-foreground">
                {t("app.settings.permissions.roles.title")}
              </h3>
              <p className="text-sm text-muted-foreground">
                {t("app.settings.permissions.roles.description")}
              </p>
            </div>
          </div>

          <div className="mt-6 grid gap-4 md:grid-cols-3">
            <div className="rounded-lg border border-border/70 bg-background p-4">
              <div className="flex items-center gap-2 mb-2">
                <CrownIcon className="size-4 text-yellow-500" weight="fill" />
                <span className="font-medium text-sm">
                  {t("app.settings.permissions.roles.superadmin.title")}
                </span>
              </div>
              <p className="text-xs text-muted-foreground">
                {t("app.settings.permissions.roles.superadmin.description")}
              </p>
            </div>

            <div className="rounded-lg border border-border/70 bg-background p-4">
              <div className="flex items-center gap-2 mb-2">
                <ShieldCheckIcon className="size-4 text-blue-500" weight="fill" />
                <span className="font-medium text-sm">
                  {t("app.settings.permissions.roles.groupAdmin.title")}
                </span>
              </div>
              <p className="text-xs text-muted-foreground">
                {t("app.settings.permissions.roles.groupAdmin.description")}
              </p>
            </div>

            <div className="rounded-lg border border-border/70 bg-background p-4">
              <div className="flex items-center gap-2 mb-2">
                <UserIcon className="size-4 text-muted-foreground" weight="fill" />
                <span className="font-medium text-sm">
                  {t("app.settings.permissions.roles.user.title")}
                </span>
              </div>
              <p className="text-xs text-muted-foreground">
                {t("app.settings.permissions.roles.user.description")}
              </p>
            </div>
          </div>
        </div>
      </section>

      <section className="space-y-4">
        <Card>
          <CardHeader>
            <CardTitle>{t("app.settings.permissions.registration.title")}</CardTitle>
            <CardDescription>
              {t("app.settings.permissions.registration.description")}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              {t("app.settings.permissions.registration.content")}
            </p>
          </CardContent>
        </Card>
      </section>
    </main>
  );
};
