import { CrownSimpleIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Badge } from "@/components/ui/badge";
import type { GroupMember } from "@/routes/groups/types";

export const MemberRoleBadge = ({ role }: { role: GroupMember["role"] }) => {
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
