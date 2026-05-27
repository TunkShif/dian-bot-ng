import {
  DownloadSimpleIcon,
  UsersIcon,
  UsersThreeIcon,
  GameControllerIcon,
} from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useQueryClient } from "@tanstack/react-query";

export const handle = { pageTitleKey: "app.settings.export.pageTitle" } as const;

const API_BASE = "/api";

function downloadFile(url: string, filename: string) {
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

export const Component = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  const handleExport = async (type: "users" | "groups" | "steam-players") => {
    try {
      const response = await fetch(`${API_BASE}/export/${type}`, {
        credentials: "include",
      });

      if (!response.ok) {
        throw new Error("Export failed");
      }

      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const filename = `${type}_export_${new Date().toISOString().slice(0, 10)}.csv`;
      downloadFile(url, filename);
      window.URL.revokeObjectURL(url);
    } catch (error) {
      console.error("Export failed:", error);
    }
  };

  return (
    <main className="mx-auto flex w-full max-w-5xl flex-col gap-6 px-4 lg:px-6">
      <header className="flex flex-col gap-2">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
          <div className="space-y-1">
            <h1 className="font-heading text-2xl font-semibold tracking-normal text-foreground md:text-3xl">
              {t("app.settings.export.title")}
            </h1>
            <p className="max-w-2xl text-sm text-muted-foreground">
              {t("app.settings.export.description")}
            </p>
          </div>
        </div>
      </header>

      <section className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        <Card>
          <CardHeader className="pb-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <UsersIcon className="size-5" weight="duotone" />
            </div>
            <CardTitle className="text-base">
              {t("app.settings.export.users.title")}
            </CardTitle>
            <CardDescription>
              {t("app.settings.export.users.description")}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="mb-4 text-sm text-muted-foreground">
              {t("app.settings.export.users.content")}
            </p>
            <Button
              variant="outline"
              className="w-full"
              onClick={() => handleExport("users")}
            >
              <DownloadSimpleIcon className="mr-2 size-4" />
              {t("app.settings.export.download")}
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <UsersThreeIcon className="size-5" weight="duotone" />
            </div>
            <CardTitle className="text-base">
              {t("app.settings.export.groups.title")}
            </CardTitle>
            <CardDescription>
              {t("app.settings.export.groups.description")}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="mb-4 text-sm text-muted-foreground">
              {t("app.settings.export.groups.content")}
            </p>
            <Button
              variant="outline"
              className="w-full"
              onClick={() => handleExport("groups")}
            >
              <DownloadSimpleIcon className="mr-2 size-4" />
              {t("app.settings.export.download")}
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <GameControllerIcon className="size-5" weight="duotone" />
            </div>
            <CardTitle className="text-base">
              {t("app.settings.export.steamPlayers.title")}
            </CardTitle>
            <CardDescription>
              {t("app.settings.export.steamPlayers.description")}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="mb-4 text-sm text-muted-foreground">
              {t("app.settings.export.steamPlayers.content")}
            </p>
            <Button
              variant="outline"
              className="w-full"
              onClick={() => handleExport("steam-players")}
            >
              <DownloadSimpleIcon className="mr-2 size-4" />
              {t("app.settings.export.download")}
            </Button>
          </CardContent>
        </Card>
      </section>
    </main>
  );
};
