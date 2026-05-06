import { RobotIcon } from "@phosphor-icons/react";
import { useMemo } from "react";
import { useTranslation } from "react-i18next";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { GroupMemberSteamSummary } from "@/routes/groups/group-member-steam-summary";
import { MemberActionsMenu } from "@/routes/groups/member-actions-menu";
import { MemberRoleBadge } from "@/routes/groups/member-role-badge";
import type { GroupMember } from "@/routes/groups/types";
import { getAvatarFallback } from "@/routes/groups/utils";

type MembersTableProps = {
  members: GroupMember[];
  groupId: string;
  canManageSteam: boolean;
};

export const MembersTable = ({ members, groupId, canManageSteam }: MembersTableProps) => {
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
            <TableHead className="hidden lg:table-cell">{t("app.groups.members.table.steam")}</TableHead>
            {canManageSteam ? (
              <TableHead className="w-12 text-right">{t("app.groups.members.table.actions")}</TableHead>
            ) : null}
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
                    <div className="pt-1 lg:hidden">
                      <GroupMemberSteamSummary steamPlayer={member.steam_player} />
                    </div>
                  </div>
                </div>
              </TableCell>
              <TableCell className="hidden sm:table-cell">
                <MemberRoleBadge role={member.role} />
              </TableCell>
              <TableCell className="hidden md:table-cell text-muted-foreground">
                {dateFormatter.format(new Date(member.join_time * 1000))}
              </TableCell>
              <TableCell className="hidden lg:table-cell">
                <GroupMemberSteamSummary steamPlayer={member.steam_player} />
              </TableCell>
              {canManageSteam ? (
                <TableCell className="text-right">
                  <MemberActionsMenu groupId={groupId} member={member} />
                </TableCell>
              ) : null}
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
};
