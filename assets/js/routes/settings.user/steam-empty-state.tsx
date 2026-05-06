import { SteamLogoIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Empty, EmptyDescription, EmptyHeader, EmptyMedia, EmptyTitle } from "@/components/ui/empty";

export const SteamEmptyState = () => {
  const { t } = useTranslation();

  return (
    <Empty className="border border-dashed">
      <EmptyHeader>
        <EmptyMedia variant="icon">
          <SteamLogoIcon />
        </EmptyMedia>
        <EmptyTitle>{t("app.settings.steam.notBound.title")}</EmptyTitle>
        <EmptyDescription>{t("app.settings.steam.notBound.description")}</EmptyDescription>
      </EmptyHeader>
    </Empty>
  );
};
