import { WarningCircleIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";
import { EmptyState } from "@/routes/groups/empty-state";

type GroupListErrorProps = {
  onRetry: () => void;
};

export const GroupListError = ({ onRetry }: GroupListErrorProps) => {
  const { t } = useTranslation();

  return (
    <EmptyState
      icon={<WarningCircleIcon className="size-5" weight="duotone" />}
      title={t("app.groups.list.error.title")}
      description={t("app.groups.list.error.description")}
      action={<Button onClick={onRetry}>{t("app.groups.actions.retry")}</Button>}
    />
  );
};
