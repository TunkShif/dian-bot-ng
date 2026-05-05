import { WarningCircleIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { EmptyState } from "@/routes/groups/empty-state";

type GroupDetailsErrorProps = {
  onRetry: () => void;
};

export const GroupDetailsError = ({ onRetry }: GroupDetailsErrorProps) => {
  const { t } = useTranslation();

  return (
    <Card className="min-w-0">
      <CardContent className="py-8">
        <EmptyState
          icon={<WarningCircleIcon className="size-5" weight="duotone" />}
          title={t("app.groups.details.error.title")}
          description={t("app.groups.details.error.description")}
          action={<Button onClick={onRetry}>{t("app.groups.actions.retry")}</Button>}
        />
      </CardContent>
    </Card>
  );
};
