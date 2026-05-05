import { useTranslation } from "react-i18next";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { GroupAccessBadge } from "@/routes/groups/group-access-badge";
import { GroupAvatar } from "@/routes/groups/group-avatar";
import { GroupStatusBadge } from "@/routes/groups/group-status-badge";
import type { GroupListItem } from "@/routes/groups/types";

type GroupListProps = {
  groups: GroupListItem[];
  selectedGroupId: number | null;
  onSelectGroup: (groupId: number) => void;
};

export const GroupList = ({ groups, selectedGroupId, onSelectGroup }: GroupListProps) => {
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
