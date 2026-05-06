import { SteamLogoIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { SteamPlayerSummaryCard } from "@/components/steam-player-summary-card";
import { Card, CardAction, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { useCurrentUser } from "@/hooks/use-current-user";
import { useBoundSteamPlayer } from "@/lib/steam";
import { BindSteamDialog } from "@/routes/settings.user/bind-steam-dialog";
import { SteamEmptyState } from "@/routes/settings.user/steam-empty-state";
import { SteamErrorState } from "@/routes/settings.user/steam-error-state";
import { SteamLoadingState } from "@/routes/settings.user/steam-loading-state";

export const SteamSection = () => {
  const { t } = useTranslation();
  const user = useCurrentUser();
  const boundPlayerQuery = useBoundSteamPlayer(user?.qq_id ?? null);
  const { data: player, isLoading, isError } = boundPlayerQuery;

  return (
    <Card>
      <CardHeader>
        <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
          <SteamLogoIcon className="size-5" weight="duotone" />
        </div>
        <CardTitle>{t("app.settings.steam.title")}</CardTitle>
        <CardDescription>{t("app.settings.steam.description")}</CardDescription>
        <CardAction>
          <BindSteamDialog />
        </CardAction>
      </CardHeader>
      <CardContent>
        {isLoading ? <SteamLoadingState /> : null}
        {isError ? <SteamErrorState onRetry={() => void boundPlayerQuery.refetch()} /> : null}
        {!isLoading && !isError && player ? <SteamPlayerSummaryCard player={player} /> : null}
        {!isLoading && !isError && !player ? <SteamEmptyState /> : null}
      </CardContent>
    </Card>
  );
};
