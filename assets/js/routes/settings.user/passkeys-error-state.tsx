import { ArrowClockwiseIcon, WarningCircleIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";
import { Empty, EmptyContent, EmptyDescription, EmptyHeader, EmptyMedia, EmptyTitle } from "@/components/ui/empty";

type PasskeysErrorStateProps = {
  onRetry: () => void;
};

export const PasskeysErrorState = ({ onRetry }: PasskeysErrorStateProps) => {
  const { t } = useTranslation();

  return (
    <Empty className="border border-dashed">
      <EmptyHeader>
        <EmptyMedia variant="icon">
          <WarningCircleIcon />
        </EmptyMedia>
        <EmptyTitle>{t("app.settings.passkeys.error.title")}</EmptyTitle>
        <EmptyDescription>{t("app.settings.passkeys.error.description")}</EmptyDescription>
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
