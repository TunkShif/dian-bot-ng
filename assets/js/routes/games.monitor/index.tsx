import { MonitorPlayIcon } from "@phosphor-icons/react";
import { useQuery } from "@tanstack/react-query";
import { useTranslation } from "react-i18next";
import { listGroupsOptions } from "@/client/@tanstack/react-query.gen";
import { GroupSteamMonitorCard } from "@/routes/games.monitor/group-steam-monitor-card";
import { MonitorEmpty } from "@/routes/games.monitor/monitor-empty";
import { MonitorError } from "@/routes/games.monitor/monitor-error";
import { MonitorLoading } from "@/routes/games.monitor/monitor-loading";

export const handle = { pageTitleKey: "app.monitor.pageTitle" } as const;

export const Component = () => {
  const { t } = useTranslation();
  const groupsQuery = useQuery(listGroupsOptions());
  const groups = groupsQuery.data?.data.groups ?? [];

  const enabledGroups = groups.filter((g) => g.enabled);

  return (
    <main className="mx-auto flex w-full max-w-7xl flex-col gap-6 px-4 pb-8 lg:px-6">
      <header className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
        <div className="space-y-1">
          <div className="flex items-center gap-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <MonitorPlayIcon className="size-5" weight="duotone" />
            </div>
            <div>
              <h1 className="font-heading text-2xl font-semibold tracking-normal text-foreground md:text-3xl">
                {t("app.monitor.title")}
              </h1>
              <p className="max-w-2xl text-sm text-muted-foreground">
                {t("app.monitor.description")}
              </p>
            </div>
          </div>
        </div>
        <div className="flex items-center gap-3 text-sm text-muted-foreground">
          <span className="inline-flex items-center gap-1.5 rounded-full border border-border/70 bg-muted/40 px-3 py-1">
            <span className="size-2 rounded-full bg-emerald-500" />
            {t("app.monitor.groupsCount", { count: enabledGroups.length })}
          </span>
        </div>
      </header>

      {groupsQuery.isLoading ? <MonitorLoading /> : null}
      {groupsQuery.isError ? (
        <MonitorError onRetry={() => void groupsQuery.refetch()} />
      ) : null}
      {groupsQuery.isSuccess && enabledGroups.length === 0 ? (
        <MonitorEmpty />
      ) : null}
      {groupsQuery.isSuccess && enabledGroups.length > 0 ? (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {enabledGroups.map((group) => (
            <GroupSteamMonitorCard key={group.group_id} group={group} />
          ))}
        </div>
      ) : null}
    </main>
  );
};
