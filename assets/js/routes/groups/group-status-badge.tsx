import { CheckCircleIcon, XCircleIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Badge } from "@/components/ui/badge";

export const GroupStatusBadge = ({ enabled }: { enabled: boolean }) => {
  const { t } = useTranslation();

  return enabled ? (
    <Badge>
      <CheckCircleIcon data-icon="inline-start" weight="fill" />
      {t("app.groups.status.enabled")}
    </Badge>
  ) : (
    <Badge variant="outline">
      <XCircleIcon data-icon="inline-start" />
      {t("app.groups.status.disabled")}
    </Badge>
  );
};
