import { ShieldCheckIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Badge } from "@/components/ui/badge";

export const GroupAccessBadge = ({ isAdmin }: { isAdmin: boolean }) => {
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
