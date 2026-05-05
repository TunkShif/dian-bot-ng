import { MagnifyingGlassIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Input } from "@/components/ui/input";
import { NativeSelect, NativeSelectOption } from "@/components/ui/native-select";
import type { MemberRoleFilter } from "@/routes/groups/types";

type MemberFiltersProps = {
  query: string;
  role: MemberRoleFilter;
  onQueryChange: (value: string) => void;
  onRoleChange: (value: MemberRoleFilter) => void;
};

export const MemberFilters = ({ query, role, onQueryChange, onRoleChange }: MemberFiltersProps) => {
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
