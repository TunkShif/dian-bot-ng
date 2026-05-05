import { MagnifyingGlassIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import type { GroupAccessFilter, GroupStatusFilter } from "@/routes/groups/types";

type GroupFiltersProps = {
  query: string;
  status: GroupStatusFilter;
  access: GroupAccessFilter;
  onQueryChange: (value: string) => void;
  onStatusChange: (value: GroupStatusFilter) => void;
  onAccessChange: (value: GroupAccessFilter) => void;
};

export const GroupFilters = ({
  query,
  status,
  access,
  onQueryChange,
  onStatusChange,
  onAccessChange,
}: GroupFiltersProps) => {
  const { t } = useTranslation();

  const statusOptions = [
    { value: "all", label: t("app.groups.filters.status.all") },
    { value: "enabled", label: t("app.groups.filters.status.enabled") },
    { value: "disabled", label: t("app.groups.filters.status.disabled") },
  ];
  const statusLabelMap = Object.fromEntries(statusOptions.map((o) => [o.value, o.label]));

  const accessOptions = [
    { value: "all", label: t("app.groups.filters.access.all") },
    { value: "admin", label: t("app.groups.filters.access.admin") },
    { value: "member", label: t("app.groups.filters.access.member") },
  ];
  const accessLabelMap = Object.fromEntries(accessOptions.map((o) => [o.value, o.label]));

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
      <Select value={status} onValueChange={(value) => onStatusChange(value as GroupStatusFilter)}>
        <SelectTrigger className="w-full min-w-0" aria-label={t("app.groups.filters.statusLabel")}>
          <SelectValue>{(value) => statusLabelMap[value as string] ?? value}</SelectValue>
        </SelectTrigger>
        <SelectContent>
          {statusOptions.map((opt) => (
            <SelectItem key={opt.value} value={opt.value}>
              {opt.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
      <Select value={access} onValueChange={(value) => onAccessChange(value as GroupAccessFilter)}>
        <SelectTrigger className="w-full min-w-0" aria-label={t("app.groups.filters.accessLabel")}>
          <SelectValue>{(value) => accessLabelMap[value as string] ?? value}</SelectValue>
        </SelectTrigger>
        <SelectContent>
          {accessOptions.map((opt) => (
            <SelectItem key={opt.value} value={opt.value}>
              {opt.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  );
};
