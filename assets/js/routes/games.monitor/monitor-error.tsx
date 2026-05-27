import { WarningCircleIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";

type MonitorErrorProps = {
  onRetry: () => void;
};

export const MonitorError = ({ onRetry }: MonitorErrorProps) => {
  const { t } = useTranslation();

  return (
    <Card className="min-w-0">
      <CardContent className="flex min-h-80 flex-col items-center justify-center gap-4">
        <div className="flex size-12 items-center justify-center rounded-full bg-destructive/10">
          <WarningCircleIcon className="size-6 text-destructive" />
        </div>
        <div className="space-y-1 text-center">
          <p className="text-sm font-medium text-foreground">
            {t("app.monitor.error.title")}
          </p>
          <p className="text-sm text-muted-foreground">
            {t("app.monitor.error.description")}
          </p>
        </div>
        <Button variant="outline" size="sm" onClick={onRetry}>
          {t("app.groups.actions.retry")}
        </Button>
      </CardContent>
    </Card>
  );
};
