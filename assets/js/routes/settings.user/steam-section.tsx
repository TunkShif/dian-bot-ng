import { SteamLogoIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { SteamPlayerSummaryCard } from "@/components/steam-player-summary-card";
import { Button } from "@/components/ui/button";
import { Card, CardAction, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { useCurrentUser } from "@/hooks/use-current-user";
import { useBoundSteamPlayer, useUnbindSelfSteamMutation } from "@/lib/steam";
import { BindSteamDialog } from "@/routes/settings.user/bind-steam-dialog";
import { SteamEmptyState } from "@/routes/settings.user/steam-empty-state";
import { SteamErrorState } from "@/routes/settings.user/steam-error-state";
import { SteamLoadingState } from "@/routes/settings.user/steam-loading-state";
import { LinkBreakIcon, SpinnerGapIcon } from "@phosphor-icons/react";
import { useState } from "react";

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
          {player ? <UnbindSteamDialog qqId={user?.qq_id ?? null} /> : <BindSteamDialog />}
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

const UnbindSteamDialog = ({ qqId }: { qqId: string | null }) => {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const unbindMutation = useUnbindSelfSteamMutation(qqId);

  const handleConfirm = () => {
    unbindMutation.mutate(undefined, {
      onSuccess: () => {
        setOpen(false);
      },
    });
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button type="button" variant="outline" />}>
        <LinkBreakIcon data-icon="inline-start" />
        {t("app.settings.steam.unbind.trigger")}
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{t("app.settings.steam.unbind.title")}</DialogTitle>
          <DialogDescription>{t("app.settings.steam.unbind.description")}</DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <DialogClose render={<Button type="button" variant="outline" />} disabled={unbindMutation.isPending}>
            {t("app.settings.actions.cancel")}
          </DialogClose>
          <Button type="button" variant="destructive" onClick={handleConfirm} disabled={unbindMutation.isPending}>
            {unbindMutation.isPending ? (
              <SpinnerGapIcon data-icon="inline-start" className="animate-spin" />
            ) : (
              <LinkBreakIcon data-icon="inline-start" />
            )}
            {t("app.settings.steam.unbind.confirm")}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};
