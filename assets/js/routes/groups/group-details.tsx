import { parseAsInteger, parseAsString, parseAsStringLiteral, useQueryState } from "nuqs";
import { useEffect, useMemo } from "react";
import { useTranslation } from "react-i18next";
import { Card, CardAction, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { GroupAccessBadge } from "@/routes/groups/group-access-badge";
import { GroupAvatar } from "@/routes/groups/group-avatar";
import { GroupSettingsSection } from "@/routes/groups/group-settings-section";
import { GroupStatusBadge } from "@/routes/groups/group-status-badge";
import { MemberFilters } from "@/routes/groups/member-filters";
import { MemberListEmpty } from "@/routes/groups/member-list-empty";
import { MemberPagination } from "@/routes/groups/member-pagination";
import { MembersTable } from "@/routes/groups/members-table";
import type { GroupDetail as GroupDetailType } from "@/routes/groups/types";
import { filterMembers, paginateMembers } from "@/routes/groups/utils";

const memberRoleParser = parseAsStringLiteral(["all", "owner", "admin", "member", "robot"] as const).withDefault("all");
const pageParser = parseAsInteger.withDefault(1);

type GroupDetailsProps = {
  group: GroupDetailType;
};

export const GroupDetails = ({ group }: GroupDetailsProps) => {
  const { t } = useTranslation();
  const [memberQuery, setMemberQuery] = useQueryState("memberQ", parseAsString.withDefault(""));
  const [memberRole, setMemberRole] = useQueryState("memberRole", memberRoleParser);
  const [memberPage, setMemberPage] = useQueryState("memberPage", pageParser);
  const filteredMembers = useMemo(
    () => filterMembers(group.members, { query: memberQuery, role: memberRole }),
    [group.members, memberQuery, memberRole],
  );
  const paginatedMembers = useMemo(() => paginateMembers(filteredMembers, memberPage), [filteredMembers, memberPage]);

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
        <GroupSettingsSection group={group} />

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
              <MembersTable
                members={paginatedMembers.members}
                groupId={group.group_id.toString()}
                canManageSteam={group.is_admin}
              />
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
