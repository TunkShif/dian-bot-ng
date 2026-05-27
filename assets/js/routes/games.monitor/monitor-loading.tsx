import { SpinnerGapIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Card, CardContent } from "@/components/ui/card";

export const MonitorLoading = () => {
  const { t } = useTranslation();

  return (
    <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
      {Array.from({ length: 6 }).map((_, i) => (
        <Card key={i} className="min-w-0 overflow-hidden">
          <CardContent className="flex min-h-60 items-center justify-center">
            <div className="flex flex-col items-center gap-3 text-muted-foreground">
              <SpinnerGapIcon className="size-6 animate-spin" />
              <span className="text-sm">{t("app.monitor.loading")}</span>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );
};
