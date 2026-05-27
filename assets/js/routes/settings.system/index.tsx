import { GearSixIcon, ShieldCheckIcon, UsersThreeIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

export const handle = { pageTitleKey: "app.settings.system.pageTitle" } as const;

export const Component = () => {
  const { t } = useTranslation();

  return (
    <main className="mx-auto flex w-full max-w-5xl flex-col gap-6 px-4 lg:px-6">
      <header className="flex flex-col gap-2">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
          <div className="space-y-1">
            <h1 className="font-heading text-2xl font-semibold tracking-normal text-foreground md:text-3xl">
              {t("app.settings.system.title")}
            </h1>
            <p className="max-w-2xl text-sm text-muted-foreground">
              {t("app.settings.system.description")}
            </p>
          </div>
        </div>
      </header>

      <section className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        <Card>
          <CardHeader className="pb-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <GearSixIcon className="size-5" weight="duotone" />
            </div>
            <CardTitle className="text-base">
              {t("app.settings.system.globalConfig.title")}
            </CardTitle>
            <CardDescription>
              {t("app.settings.system.globalConfig.description")}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              {t("app.settings.system.globalConfig.content")}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <ShieldCheckIcon className="size-5" weight="duotone" />
            </div>
            <CardTitle className="text-base">
              {t("app.settings.system.superadmin.title")}
            </CardTitle>
            <CardDescription>
              {t("app.settings.system.superadmin.description")}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              {t("app.settings.system.superadmin.content")}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <UsersThreeIcon className="size-5" weight="duotone" />
            </div>
            <CardTitle className="text-base">
              {t("app.settings.system.userManagement.title")}
            </CardTitle>
            <CardDescription>
              {t("app.settings.system.userManagement.description")}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              {t("app.settings.system.userManagement.content")}
            </p>
          </CardContent>
        </Card>
      </section>
    </main>
  );
};
