import {
  CheckCircleIcon,
  CrownSimpleIcon,
  MagnifyingGlassIcon,
  RobotIcon,
  ShieldCheckIcon,
  SlidersHorizontalIcon,
  UsersThreeIcon,
  WarningCircleIcon,
  XCircleIcon,
} from "@phosphor-icons/react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { parseAsInteger, parseAsString, parseAsStringLiteral, useQueryState } from "nuqs";
import type React from "react";
import { useEffect, useMemo } from "react";
import { useTranslation } from "react-i18next";
import {
  listGroupsOptions,
  listGroupsQueryKey,
  showGroupOptions,
  showGroupQueryKey,
  updateGroupMutation,
} from "@/client/@tanstack/react-query.gen";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardAction, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { NativeSelect, NativeSelectOption } from "@/components/ui/native-select";
import { Skeleton } from "@/components/ui/skeleton";
import { Switch } from "@/components/ui/switch";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { cn } from "@/lib/utils";
import type {
  GroupAccessFilter,
  GroupDetail,
  GroupListItem,
  GroupMember,
  GroupStatusFilter,
  MemberRoleFilter,
} from "@/routes/groups/types";
import { filterGroups, filterMembers, paginateGroups, paginateMembers } from "@/routes/groups/utils";

const statusParser = parseAsStringLiteral(["all", "enabled", "disabled"] as const).withDefault("all");
const accessParser = parseAsStringLiteral(["all", "admin", "member"] as const).withDefault("all");
const memberRoleParser = parseAsStringLiteral(["all", "owner", "admin", "member", "robot"] as const).withDefault("all");
const pageParser = parseAsInteger.withDefault(1);

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

type GroupSummaryProps = {
  groups: GroupListItem[];
};

const GroupSummary = ({ groups }: GroupSummaryProps) => {
  const { t } = useTranslation();
  const enabledCount = groups.filter((group) => group.enabled).length;
  const adminCount = groups.filter((group) => group.is_admin).length;

  return (
    <div className="grid grid-cols-3 gap-2 sm:min-w-80">
      <SummaryMetric label={t("app.groups.summary.total")} value={groups.length} />
      <SummaryMetric label={t("app.groups.summary.enabled")} value={enabledCount} />
      <SummaryMetric label={t("app.groups.summary.admin")} value={adminCount} />
    </div>
  );
};

type SummaryMetricProps = {
  label: string;
  value: number;
};

const SummaryMetric = ({ label, value }: SummaryMetricProps) => (
  <div className="rounded-xl border border-border/70 bg-card/80 px-3 py-2 shadow-sm shadow-foreground/3">
    <div className="text-lg font-semibold tabular-nums text-foreground">{value}</div>
    <div className="truncate text-xs text-muted-foreground">{label}</div>
  </div>
);

type GroupFiltersProps = {
  query: string;
  status: GroupStatusFilter;
  access: GroupAccessFilter;
  onQueryChange: (value: string) => void;
  onStatusChange: (value: GroupStatusFilter) => void;
  onAccessChange: (value: GroupAccessFilter) => void;
};

const GroupFilters = ({ query, status, access, onQueryChange, onStatusChange, onAccessChange }: GroupFiltersProps) => {
  const { t } = useTranslation();

  return (
    <div className="grid gap-3 md:grid-cols-2 2xl:grid-cols-[minmax(180px,1fr)_minmax(8.5rem,0.45fr)_minmax(8.5rem,0.45fr)]">
      <label className="relative block md:col-span-2 2xl:col-span-1" htmlFor="groups-search-input">
        <span className="sr-only">{t("app.groups.filters.searchLabel")}</span>
        <MagnifyingGlassIcon className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          id="groups-search-input"
          value={query}
          onChange={(event) => onQueryChange(event.target.value)}
          placeholder={t("app.groups.filters.searchPlaceholder")}
          className="pl-9"
        />
      </label>
      <NativeSelect
        value={status}
        onChange={(event) => onStatusChange(event.target.value as GroupStatusFilter)}
        aria-label={t("app.groups.filters.statusLabel")}
        className="w-full min-w-0"
      >
        <NativeSelectOption value="all">{t("app.groups.filters.status.all")}</NativeSelectOption>
        <NativeSelectOption value="enabled">{t("app.groups.filters.status.enabled")}</NativeSelectOption>
        <NativeSelectOption value="disabled">{t("app.groups.filters.status.disabled")}</NativeSelectOption>
      </NativeSelect>
      <NativeSelect
        value={access}
        onChange={(event) => onAccessChange(event.target.value as GroupAccessFilter)}
        aria-label={t("app.groups.filters.accessLabel")}
        className="w-full min-w-0"
      >
        <NativeSelectOption value="all">{t("app.groups.filters.access.all")}</NativeSelectOption>
        <NativeSelectOption value="admin">{t("app.groups.filters.access.admin")}</NativeSelectOption>
        <NativeSelectOption value="member">{t("app.groups.filters.access.member")}</NativeSelectOption>
      </NativeSelect>
    </div>
  );
};

type GroupListProps = {
  groups: GroupListItem[];
  selectedGroupId: number | null;
  onSelectGroup: (groupId: number) => void;
};

const GroupList = ({ groups, selectedGroupId, onSelectGroup }: GroupListProps) => {
  const { t } = useTranslation();

  return (
    <div className="overflow-hidden rounded-xl border border-border/70">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{t("app.groups.list.table.group")}</TableHead>
            <TableHead className="hidden sm:table-cell">{t("app.groups.list.table.members")}</TableHead>
            <TableHead>{t("app.groups.list.table.status")}</TableHead>
            <TableHead className="hidden md:table-cell">{t("app.groups.list.table.access")}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {groups.map((group) => (
            <TableRow
              key={group.group_id}
              data-state={selectedGroupId === group.group_id ? "selected" : undefined}
              className="cursor-pointer"
              onClick={() => onSelectGroup(group.group_id)}
            >
              <TableCell className="min-w-0 whitespace-normal">
                <div className="flex min-w-0 items-center gap-3">
                  <GroupAvatar group={group} />
                  <div className="min-w-0">
                    <div className="truncate font-medium text-foreground">{group.group_name}</div>
                    <div className="truncate text-xs text-muted-foreground">{group.group_id}</div>
                  </div>
                </div>
              </TableCell>
              <TableCell className="hidden sm:table-cell tabular-nums">{group.member_count}</TableCell>
              <TableCell>
                <GroupStatusBadge enabled={group.enabled} />
              </TableCell>
              <TableCell className="hidden md:table-cell">
                <GroupAccessBadge isAdmin={group.is_admin} />
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
};

type GroupDetailsPanelProps = {
  group: GroupListItem | undefined;
};

const GroupDetailsPanel = ({ group }: GroupDetailsPanelProps) => {
  const { t } = useTranslation();
  const groupId = group?.group_id;
  const detailQuery = useQuery({
    ...showGroupOptions({ path: { id: (groupId ?? 0).toString() } }),
    enabled: typeof groupId === "number",
  });

  if (!group) {
    return (
      <Card className="min-w-0">
        <CardContent className="flex min-h-80 items-center justify-center py-12 text-sm text-muted-foreground">
          {t("app.groups.details.noSelection")}
        </CardContent>
      </Card>
    );
  }

  if (detailQuery.isLoading) {
    return <GroupDetailsLoading />;
  }

  if (detailQuery.isError) {
    return <GroupDetailsError onRetry={() => void detailQuery.refetch()} />;
  }

  const detail = detailQuery.data?.data.group;

  return detail ? <GroupDetails group={detail} /> : null;
};

type GroupDetailsProps = {
  group: GroupDetail;
};

const GroupDetails = ({ group }: GroupDetailsProps) => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [memberQuery, setMemberQuery] = useQueryState("memberQ", parseAsString.withDefault(""));
  const [memberRole, setMemberRole] = useQueryState("memberRole", memberRoleParser);
  const [memberPage, setMemberPage] = useQueryState("memberPage", pageParser);
  const filteredMembers = useMemo(
    () => filterMembers(group.members, { query: memberQuery, role: memberRole }),
    [group.members, memberQuery, memberRole],
  );
  const paginatedMembers = useMemo(() => paginateMembers(filteredMembers, memberPage), [filteredMembers, memberPage]);
  const { mutate, isPending } = useMutation({
    ...updateGroupMutation(),
    meta: {
      successMessage: t("app.groups.settings.update.successMessage"),
      errorMessage: t("app.groups.settings.update.errorMessage"),
    },
  });

  const handleEnabledChange = (enabled: boolean) => {
    mutate(
      {
        path: { id: group.group_id.toString() },
        body: { enabled },
      },
      {
        onSuccess: () => {
          void queryClient.invalidateQueries({ queryKey: listGroupsQueryKey() });
          void queryClient.invalidateQueries({
            queryKey: showGroupQueryKey({ path: { id: group.group_id.toString() } }),
          });
        },
      },
    );
  };

  useEffect(() => {
    if (memberPage !== paginatedMembers.page) {
      void setMemberPage(paginatedMembers.page, { history: "replace" });
    }
  }, [memberPage, paginatedMembers.page, setMemberPage]);

  const handleMemberFilterChange = (callback: () => void) => {
    callback();
    void setMemberPage(1);
  };

  return (
    <Card className="min-w-0">
      <CardHeader>
        <div className="flex min-w-0 items-center gap-3">
          <GroupAvatar group={group} size="lg" />
          <div className="min-w-0">
            <CardTitle className="truncate">{group.group_name}</CardTitle>
            <CardDescription className="truncate">{group.group_id}</CardDescription>
          </div>
        </div>
        <CardAction className="flex items-center gap-2">
          <GroupStatusBadge enabled={group.enabled} />
          <GroupAccessBadge isAdmin={group.is_admin} />
        </CardAction>
      </CardHeader>
      <CardContent className="space-y-5">
        <section className="rounded-xl border border-border/70 bg-muted/30 p-4">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div className="space-y-1">
              <div className="flex items-center gap-2 text-sm font-medium text-foreground">
                <SlidersHorizontalIcon className="size-4 text-muted-foreground" />
                {t("app.groups.settings.title")}
              </div>
              <p className="max-w-md text-sm text-muted-foreground">
                {group.is_admin ? t("app.groups.settings.description") : t("app.groups.settings.adminOnlyDescription")}
              </p>
            </div>
            <label
              className="flex shrink-0 items-center justify-between gap-3 rounded-full border border-border/70 bg-background px-3 py-2 text-sm font-medium shadow-sm shadow-foreground/3"
              htmlFor="group-enabled-switch"
            >
              <span>{group.enabled ? t("app.groups.status.enabled") : t("app.groups.status.disabled")}</span>
              <Switch
                id="group-enabled-switch"
                checked={group.enabled}
                disabled={!group.is_admin || isPending}
                onCheckedChange={handleEnabledChange}
                aria-label={t("app.groups.settings.enabledLabel")}
              />
            </label>
          </div>
        </section>

        <section className="space-y-3">
          <div className="flex items-center justify-between gap-3">
            <div>
              <h2 className="font-heading text-base font-medium text-foreground">{t("app.groups.members.title")}</h2>
              <p className="text-sm text-muted-foreground">
                {t("app.groups.members.count", { count: group.member_count })}
              </p>
            </div>
          </div>
          <MemberFilters
            query={memberQuery}
            role={memberRole}
            onQueryChange={(value) => handleMemberFilterChange(() => void setMemberQuery(value || null))}
            onRoleChange={(value) => handleMemberFilterChange(() => void setMemberRole(value))}
          />
          {filteredMembers.length === 0 ? (
            <MemberListEmpty />
          ) : (
            <>
              <MembersTable members={paginatedMembers.members} />
              <MemberPagination
                page={paginatedMembers.page}
                totalPages={paginatedMembers.totalPages}
                totalItems={filteredMembers.length}
                onPageChange={(nextPage) => void setMemberPage(nextPage)}
              />
            </>
          )}
        </section>
      </CardContent>
    </Card>
  );
};

type MemberFiltersProps = {
  query: string;
  role: MemberRoleFilter;
  onQueryChange: (value: string) => void;
  onRoleChange: (value: MemberRoleFilter) => void;
};

const MemberFilters = ({ query, role, onQueryChange, onRoleChange }: MemberFiltersProps) => {
  const { t } = useTranslation();

  return (
    <div className="grid gap-3 sm:grid-cols-[minmax(180px,1fr)_180px]">
      <label className="relative block" htmlFor="members-search-input">
        <span className="sr-only">{t("app.groups.members.filters.searchLabel")}</span>
        <MagnifyingGlassIcon className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          id="members-search-input"
          value={query}
          onChange={(event) => onQueryChange(event.target.value)}
          placeholder={t("app.groups.members.filters.searchPlaceholder")}
          className="pl-9"
        />
      </label>
      <NativeSelect
        value={role}
        onChange={(event) => onRoleChange(event.target.value as MemberRoleFilter)}
        aria-label={t("app.groups.members.filters.roleLabel")}
        className="w-full"
      >
        <NativeSelectOption value="all">{t("app.groups.members.filters.role.all")}</NativeSelectOption>
        <NativeSelectOption value="owner">{t("app.groups.members.filters.role.owner")}</NativeSelectOption>
        <NativeSelectOption value="admin">{t("app.groups.members.filters.role.admin")}</NativeSelectOption>
        <NativeSelectOption value="member">{t("app.groups.members.filters.role.member")}</NativeSelectOption>
        <NativeSelectOption value="robot">{t("app.groups.members.filters.role.robot")}</NativeSelectOption>
      </NativeSelect>
    </div>
  );
};

type MembersTableProps = {
  members: GroupMember[];
};

const MembersTable = ({ members }: MembersTableProps) => {
  const { t, i18n } = useTranslation();
  const dateFormatter = useMemo(
    () =>
      new Intl.DateTimeFormat(i18n.language, {
        dateStyle: "medium",
      }),
    [i18n.language],
  );

  return (
    <div className="overflow-hidden rounded-xl border border-border/70">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{t("app.groups.members.table.member")}</TableHead>
            <TableHead className="hidden sm:table-cell">{t("app.groups.members.table.role")}</TableHead>
            <TableHead className="hidden md:table-cell">{t("app.groups.members.table.joined")}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {members.map((member) => (
            <TableRow key={member.user_id}>
              <TableCell className="min-w-0 whitespace-normal">
                <div className="flex min-w-0 items-center gap-3">
                  <Avatar>
                    <AvatarImage src={member.avatar_url} alt="" />
                    <AvatarFallback>{getAvatarFallback(member.display_name || member.nickname)}</AvatarFallback>
                  </Avatar>
                  <div className="min-w-0">
                    <div className="flex min-w-0 items-center gap-2">
                      <span className="truncate font-medium text-foreground">
                        {member.display_name || member.nickname}
                      </span>
                      {member.is_robot ? (
                        <Badge variant="outline" className="shrink-0">
                          <RobotIcon data-icon="inline-start" />
                          {t("app.groups.members.robot")}
                        </Badge>
                      ) : null}
                    </div>
                    <div className="truncate text-xs text-muted-foreground">{member.user_id}</div>
                  </div>
                </div>
              </TableCell>
              <TableCell className="hidden sm:table-cell">
                <MemberRoleBadge role={member.role} />
              </TableCell>
              <TableCell className="hidden md:table-cell text-muted-foreground">
                {dateFormatter.format(new Date(member.join_time * 1000))}
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
};

type GroupPaginationProps = {
  page: number;
  totalPages: number;
  totalItems: number;
  onPageChange: (page: number) => void;
};

const GroupPagination = ({ page, totalPages, totalItems, onPageChange }: GroupPaginationProps) => {
  const { t } = useTranslation();

  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
      <p className="text-sm text-muted-foreground">
        {t("app.groups.pagination.page")} {page} {t("app.groups.pagination.of")} {totalPages} ·{" "}
        {t("app.groups.pagination.total", { count: totalItems })}
      </p>
      <div className="flex items-center gap-2">
        <Button type="button" variant="outline" size="sm" disabled={page <= 1} onClick={() => onPageChange(page - 1)}>
          {t("app.groups.pagination.previous")}
        </Button>
        <Button
          type="button"
          variant="outline"
          size="sm"
          disabled={page >= totalPages}
          onClick={() => onPageChange(page + 1)}
        >
          {t("app.groups.pagination.next")}
        </Button>
      </div>
    </div>
  );
};

type MemberPaginationProps = {
  page: number;
  totalPages: number;
  totalItems: number;
  onPageChange: (page: number) => void;
};

const MemberPagination = ({ page, totalPages, totalItems, onPageChange }: MemberPaginationProps) => {
  const { t } = useTranslation();

  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
      <p className="text-sm text-muted-foreground">
        {t("app.groups.members.pagination.page")} {page} {t("app.groups.members.pagination.of")} {totalPages} ·{" "}
        {t("app.groups.members.pagination.total", { count: totalItems })}
      </p>
      <div className="flex items-center gap-2">
        <Button type="button" variant="outline" size="sm" disabled={page <= 1} onClick={() => onPageChange(page - 1)}>
          {t("app.groups.members.pagination.previous")}
        </Button>
        <Button
          type="button"
          variant="outline"
          size="sm"
          disabled={page >= totalPages}
          onClick={() => onPageChange(page + 1)}
        >
          {t("app.groups.members.pagination.next")}
        </Button>
      </div>
    </div>
  );
};

const GroupListLoading = () => (
  <div className="space-y-3">
    {["one", "two", "three", "four", "five"].map((row) => (
      <Skeleton key={row} className="h-16 w-full" />
    ))}
  </div>
);

const GroupDetailsLoading = () => (
  <Card className="min-w-0">
    <CardHeader>
      <Skeleton className="size-10 rounded-full" />
      <Skeleton className="h-5 w-40" />
      <Skeleton className="h-4 w-56" />
    </CardHeader>
    <CardContent className="space-y-4">
      <Skeleton className="h-28 w-full" />
      <Skeleton className="h-64 w-full" />
    </CardContent>
  </Card>
);

type RetryStateProps = {
  onRetry: () => void;
};

const GroupListError = ({ onRetry }: RetryStateProps) => {
  const { t } = useTranslation();

  return (
    <EmptyState
      icon={<WarningCircleIcon className="size-5" weight="duotone" />}
      title={t("app.groups.list.error.title")}
      description={t("app.groups.list.error.description")}
      action={<Button onClick={onRetry}>{t("app.groups.actions.retry")}</Button>}
    />
  );
};

const GroupDetailsError = ({ onRetry }: RetryStateProps) => {
  const { t } = useTranslation();

  return (
    <Card className="min-w-0">
      <CardContent className="py-8">
        <EmptyState
          icon={<WarningCircleIcon className="size-5" weight="duotone" />}
          title={t("app.groups.details.error.title")}
          description={t("app.groups.details.error.description")}
          action={<Button onClick={onRetry}>{t("app.groups.actions.retry")}</Button>}
        />
      </CardContent>
    </Card>
  );
};

const GroupListEmpty = () => {
  const { t } = useTranslation();

  return (
    <EmptyState
      icon={<MagnifyingGlassIcon className="size-5" />}
      title={t("app.groups.list.empty.title")}
      description={t("app.groups.list.empty.description")}
    />
  );
};

const MemberListEmpty = () => {
  const { t } = useTranslation();

  return (
    <EmptyState
      icon={<MagnifyingGlassIcon className="size-5" />}
      title={t("app.groups.members.empty.title")}
      description={t("app.groups.members.empty.description")}
    />
  );
};

type EmptyStateProps = {
  icon: React.ReactNode;
  title: string;
  description: string;
  action?: React.ReactNode;
};

const EmptyState = ({ icon, title, description, action }: EmptyStateProps) => (
  <div className="flex min-h-56 flex-col items-center justify-center gap-3 rounded-xl border border-dashed border-border/80 bg-muted/20 px-4 py-8 text-center">
    <div className="flex size-10 items-center justify-center rounded-xl bg-muted text-muted-foreground">{icon}</div>
    <div className="space-y-1">
      <h2 className="font-heading text-base font-medium text-foreground">{title}</h2>
      <p className="max-w-md text-sm text-muted-foreground">{description}</p>
    </div>
    {action}
  </div>
);

type GroupAvatarProps = {
  group: Pick<GroupListItem, "avatar_url" | "group_name" | "enabled">;
  size?: "default" | "lg";
};

const GroupAvatar = ({ group, size = "default" }: GroupAvatarProps) => (
  <Avatar size={size} className={cn(!group.enabled && "opacity-60 grayscale")}>
    <AvatarImage src={group.avatar_url} alt="" />
    <AvatarFallback>{getAvatarFallback(group.group_name)}</AvatarFallback>
  </Avatar>
);

const GroupStatusBadge = ({ enabled }: { enabled: boolean }) => {
  const { t } = useTranslation();

  return enabled ? (
    <Badge>
      <CheckCircleIcon data-icon="inline-start" weight="fill" />
      {t("app.groups.status.enabled")}
    </Badge>
  ) : (
    <Badge variant="outline">
      <XCircleIcon data-icon="inline-start" />
      {t("app.groups.status.disabled")}
    </Badge>
  );
};

const GroupAccessBadge = ({ isAdmin }: { isAdmin: boolean }) => {
  const { t } = useTranslation();

  return isAdmin ? (
    <Badge variant="secondary">
      <ShieldCheckIcon data-icon="inline-start" weight="duotone" />
      {t("app.groups.access.admin")}
    </Badge>
  ) : (
    <Badge variant="outline">{t("app.groups.access.member")}</Badge>
  );
};

const MemberRoleBadge = ({ role }: { role: GroupMember["role"] }) => {
  const { t } = useTranslation();

  if (role === "owner") {
    return (
      <Badge variant="secondary">
        <CrownSimpleIcon data-icon="inline-start" weight="duotone" />
        {t("app.groups.members.roles.owner")}
      </Badge>
    );
  }

  if (role === "admin") {
    return <Badge variant="secondary">{t("app.groups.members.roles.admin")}</Badge>;
  }

  return <Badge variant="outline">{t("app.groups.members.roles.member")}</Badge>;
};

const getAvatarFallback = (value: string) => value.trim().slice(0, 1).toUpperCase() || "?";
