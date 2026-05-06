import { ArrowClockwiseIcon, WarningCircleIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";
import { Empty, EmptyContent, EmptyDescription, EmptyHeader, EmptyMedia, EmptyTitle } from "@/components/ui/empty";

type SteamErrorStateProps = {
  onRetry: () => void;
};

export const SteamErrorState = ({ onRetry }: SteamErrorStateProps) => {
  const { t } = useTranslation();

  return (
    <Empty className="border border-dashed">
      <EmptyHeader>
        <EmptyMedia variant="icon">
          <WarningCircleIcon />
        </EmptyMedia>
        <EmptyTitle>{t("app.settings.steam.error.title")}</EmptyTitle>
        <EmptyDescription>{t("app.settings.steam.error.description")}</EmptyDescription>
      </EmptyHeader>
      <EmptyContent>
        <Button type="button" variant="outline" onClick={onRetry}>
          <ArrowClockwiseIcon data-icon="inline-start" />
          {t("app.settings.actions.retry")}
        </Button>
      </EmptyContent>
    </Empty>
  );
};
