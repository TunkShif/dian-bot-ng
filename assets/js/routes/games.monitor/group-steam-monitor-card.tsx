import { UsersThreeIcon } from "@phosphor-icons/react";
import { useQuery } from "@tanstack/react-query";
import { useTranslation } from "react-i18next";
import { showGroupOptions } from "@/client/@tanstack/react-query.gen";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { GroupAvatar } from "@/routes/groups/group-avatar";
import type { GroupListItem } from "@/routes/groups/types";
import { SteamMemberRow } from "@/routes/games.monitor/steam-member-row";
import { cn } from "@/lib/utils";

type GroupSteamMonitorCardProps = {
  group: GroupListItem;
};

export const GroupSteamMonitorCard = ({
  group,
}: GroupSteamMonitorCardProps) => {
  const { t } = useTranslation();
  const detailQuery = useQuery({
    ...showGroupOptions({ path: { id: group.group_id.toString() } }),
  });

  const members = detailQuery.data?.data.group.members ?? [];
  const boundMembers = members.filter((m) => m.steam_player);
  const totalMembers = members.length;

  return (
    <Card className="min-w-0 overflow-hidden">
      <CardHeader className="pb-3">
        <div className="flex min-w-0 items-center gap-3">
          <GroupAvatar group={group} size="md" />
          <div className="min-w-0 flex-1">
            <CardTitle className="truncate text-base">
              {group.group_name}
            </CardTitle>
            <CardDescription className="truncate">
              {group.group_id}
            </CardDescription>
          </div>
          <div className="flex shrink-0 items-center gap-1.5 text-xs text-muted-foreground">
            <UsersThreeIcon className="size-3.5" />
            <span>
              {t("app.monitor.boundCount", {
                bound: boundMembers.length,
                total: totalMembers,
              })}
            </span>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        {detailQuery.isLoading ? (
          <div className="flex items-center justify-center py-8 text-sm text-muted-foreground">
            {t("app.monitor.loadingMembers")}
          </div>
        ) : detailQuery.isError ? (
          <div className="flex items-center justify-center py-8 text-sm text-destructive">
            {t("app.monitor.errorMembers")}
          </div>
        ) : boundMembers.length === 0 ? (
          <div className="flex items-center justify-center py-8 text-sm text-muted-foreground">
            {t("app.monitor.noSteamBindings")}
          </div>
        ) : (
          <div className="space-y-1">
            {boundMembers.map((member) => (
              <SteamMemberRow
                key={member.user_id}
                groupId={group.group_id.toString()}
                member={member}
              />
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
};
