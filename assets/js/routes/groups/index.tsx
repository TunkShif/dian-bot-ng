import { UsersThreeIcon } from "@phosphor-icons/react";
import { useQuery } from "@tanstack/react-query";
import { parseAsInteger, parseAsString, parseAsStringLiteral, useQueryState } from "nuqs";
import { useEffect, useMemo } from "react";
import { useTranslation } from "react-i18next";
import { listGroupsOptions } from "@/client/@tanstack/react-query.gen";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { GroupDetailsPanel } from "@/routes/groups/group-details-panel";
import { GroupFilters } from "@/routes/groups/group-filters";
import { GroupList } from "@/routes/groups/group-list";
import { GroupListEmpty } from "@/routes/groups/group-list-empty";
import { GroupListError } from "@/routes/groups/group-list-error";
import { GroupListLoading } from "@/routes/groups/group-list-loading";
import { GroupPagination } from "@/routes/groups/group-pagination";
import { GroupSummary } from "@/routes/groups/group-summary";
import { filterGroups, paginateGroups } from "@/routes/groups/utils";

const statusParser = parseAsStringLiteral(["all", "enabled", "disabled"] as const).withDefault("all");
const accessParser = parseAsStringLiteral(["all", "admin", "member"] as const).withDefault("all");
const pageParser = parseAsInteger.withDefault(1);

export const handle = { pageTitleKey: "app.groups.pageTitle" } as const;

export const Component = () => {
  const { t } = useTranslation();
  const [selectedGroupId, setSelectedGroupId] = useQueryState("group", parseAsString);
  const [query, setQuery] = useQueryState("q", parseAsString.withDefault(""));
  const [status, setStatus] = useQueryState("status", statusParser);
  const [access, setAccess] = useQueryState("access", accessParser);
  const [page, setPage] = useQueryState("page", pageParser);
  const groupsQuery = useQuery(listGroupsOptions());
  const groups = groupsQuery.data?.data.groups ?? [];

  const filteredGroups = useMemo(
    () => filterGroups(groups, { query, status, access }),
    [groups, query, status, access],
  );
  const paginatedGroups = useMemo(() => paginateGroups(filteredGroups, page), [filteredGroups, page]);
  const activeGroup =
    groups.find((group) => group.group_id.toString() === selectedGroupId) ?? paginatedGroups.groups[0] ?? groups[0];

  useEffect(() => {
    if (!activeGroup) {
      return;
    }

    if (selectedGroupId !== activeGroup.group_id.toString()) {
      void setSelectedGroupId(activeGroup.group_id.toString(), { history: "replace" });
    }
  }, [activeGroup, selectedGroupId, setSelectedGroupId]);

  useEffect(() => {
    if (page !== paginatedGroups.page) {
      void setPage(paginatedGroups.page, { history: "replace" });
    }
  }, [page, paginatedGroups.page, setPage]);

  const handleFilterChange = (callback: () => void) => {
    callback();
    void setPage(1);
  };

  return (
    <main className="mx-auto flex w-full max-w-7xl flex-col gap-6 px-4 pb-8 lg:px-6">
      <header className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
        <div className="space-y-1">
          <h1 className="font-heading text-2xl font-semibold tracking-normal text-foreground md:text-3xl">
            {t("app.groups.title")}
          </h1>
          <p className="max-w-2xl text-sm text-muted-foreground">{t("app.groups.description")}</p>
        </div>
        <GroupSummary groups={groups} />
      </header>

      <section className="grid min-h-0 gap-4 xl:grid-cols-[minmax(0,0.85fr)_minmax(460px,1.15fr)]">
        <Card className="min-w-0">
          <CardHeader>
            <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <UsersThreeIcon className="size-5" weight="duotone" />
            </div>
            <CardTitle>{t("app.groups.list.title")}</CardTitle>
            <CardDescription>{t("app.groups.list.description")}</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <GroupFilters
              query={query}
              status={status}
              access={access}
              onQueryChange={(value) => handleFilterChange(() => void setQuery(value || null))}
              onStatusChange={(value) => handleFilterChange(() => void setStatus(value))}
              onAccessChange={(value) => handleFilterChange(() => void setAccess(value))}
            />

            {groupsQuery.isLoading ? <GroupListLoading /> : null}
            {groupsQuery.isError ? <GroupListError onRetry={() => void groupsQuery.refetch()} /> : null}
            {groupsQuery.isSuccess && filteredGroups.length === 0 ? <GroupListEmpty /> : null}
            {groupsQuery.isSuccess && filteredGroups.length > 0 ? (
              <>
                <GroupList
                  groups={paginatedGroups.groups}
                  selectedGroupId={activeGroup?.group_id ?? null}
                  onSelectGroup={(groupId) => void setSelectedGroupId(groupId.toString())}
                />
                <GroupPagination
                  page={paginatedGroups.page}
                  totalPages={paginatedGroups.totalPages}
                  totalItems={filteredGroups.length}
                  onPageChange={(nextPage) => void setPage(nextPage)}
                />
              </>
            ) : null}
          </CardContent>
        </Card>

        <GroupDetailsPanel group={activeGroup} />
      </section>
    </main>
  );
};
