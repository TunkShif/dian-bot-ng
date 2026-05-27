import { MonitorPlayIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Card, CardContent } from "@/components/ui/card";

export const MonitorEmpty = () => {
  const { t } = useTranslation();

  return (
    <Card className="min-w-0">
      <CardContent className="flex min-h-80 flex-col items-center justify-center gap-4">
        <div className="flex size-12 items-center justify-center rounded-full bg-muted">
          <MonitorPlayIcon className="size-6 text-muted-foreground" />
        </div>
        <div className="space-y-1 text-center">
          <p className="text-sm font-medium text-foreground">
            {t("app.monitor.empty.title")}
          </p>
          <p className="text-sm text-muted-foreground">
            {t("app.monitor.empty.description")}
          </p>
        </div>
      </CardContent>
    </Card>
  );
};
