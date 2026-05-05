import { MagnifyingGlassIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import type { MemberRoleFilter } from "@/routes/groups/types";

type MemberFiltersProps = {
  query: string;
  role: MemberRoleFilter;
  onQueryChange: (value: string) => void;
  onRoleChange: (value: MemberRoleFilter) => void;
};

export const MemberFilters = ({ query, role, onQueryChange, onRoleChange }: MemberFiltersProps) => {
  const { t } = useTranslation();

  const roleOptions = [
    { value: "all", label: t("app.groups.members.filters.role.all") },
    { value: "owner", label: t("app.groups.members.filters.role.owner") },
    { value: "admin", label: t("app.groups.members.filters.role.admin") },
    { value: "member", label: t("app.groups.members.filters.role.member") },
    { value: "robot", label: t("app.groups.members.filters.role.robot") },
  ];
  const roleLabelMap = Object.fromEntries(roleOptions.map((o) => [o.value, o.label]));

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
      <Select value={role} onValueChange={(value) => onRoleChange(value as MemberRoleFilter)}>
        <SelectTrigger className="w-full" aria-label={t("app.groups.members.filters.roleLabel")}>
          <SelectValue>{(value) => roleLabelMap[value as string] ?? value}</SelectValue>
        </SelectTrigger>
        <SelectContent>
          {roleOptions.map((opt) => (
            <SelectItem key={opt.value} value={opt.value}>
              {opt.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  );
};
