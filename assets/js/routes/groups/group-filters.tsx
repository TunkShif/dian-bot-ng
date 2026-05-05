import { MagnifyingGlassIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Input } from "@/components/ui/input";
import { NativeSelect, NativeSelectOption } from "@/components/ui/native-select";
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
