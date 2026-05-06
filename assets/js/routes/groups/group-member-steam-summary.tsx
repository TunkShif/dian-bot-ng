import { LinkSimpleIcon, SpinnerGapIcon, SteamLogoIcon } from "@phosphor-icons/react";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { SteamPlayerSummaryCard } from "@/components/steam-player-summary-card";
import { Button } from "@/components/ui/button";
import { HoverCard, HoverCardContent, HoverCardTrigger } from "@/components/ui/hover-card";
import { useSteamPlayerLookup } from "@/lib/steam";
import { BindMemberSteamDialog } from "@/routes/groups/bind-member-steam-dialog";
import type { GroupMember } from "@/routes/groups/types";

type GroupMemberSteamSummaryProps = {
  groupId: string;
  member: GroupMember;
  canManageSteam: boolean;
};

export const GroupMemberSteamSummary = ({ groupId, member, canManageSteam }: GroupMemberSteamSummaryProps) => {
  const { t } = useTranslation();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [previewOpen, setPreviewOpen] = useState(false);
  const steamPlayer = member.steam_player;
  const previewQuery = useSteamPlayerLookup(previewOpen && steamPlayer ? steamPlayer.steam_id : null);

  if (!steamPlayer && !canManageSteam) {
    return <span className="text-sm text-muted-foreground">{t("app.groups.members.steam.notLinked")}</span>;
  }

  return (
    <>
      <HoverCard open={previewOpen} onOpenChange={setPreviewOpen}>
        <HoverCardTrigger
          delay={150}
          closeDelay={100}
          render={<button type="button" />}
          className="flex min-w-0 items-center gap-2 rounded-md px-2 py-1 -mx-2 text-sm transition-colors hover:bg-accent/60 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
        >
          <SteamLogoIcon className="size-4 shrink-0 text-[#66c0f4]" weight="duotone" />
          <span className={steamPlayer ? "truncate text-foreground" : "truncate text-muted-foreground"}>
            {steamPlayer?.display_name || t("app.groups.members.steam.notLinked")}
          </span>
        </HoverCardTrigger>
        <HoverCardContent align="start" className="w-88 rounded-none bg-transparent p-0 shadow-none ring-0">
          {steamPlayer ? (
            previewQuery.isLoading ? (
              <div className="flex items-center justify-center rounded-2xl border border-border/70 bg-popover/95 p-8 text-muted-foreground shadow-2xl ring-1 ring-foreground/5 backdrop-blur-sm">
                <SpinnerGapIcon className="size-5 animate-spin" />
              </div>
            ) : previewQuery.isError ? (
              <div className="rounded-2xl border border-destructive/40 bg-popover/95 p-4 text-sm text-destructive shadow-2xl ring-1 ring-foreground/5 backdrop-blur-sm">
                {t("app.groups.members.steam.preview.error")}
              </div>
            ) : previewQuery.data ? (
              <SteamPlayerSummaryCard player={previewQuery.data} />
            ) : null
          ) : (
            <div className="rounded-2xl border border-border/70 bg-popover/95 p-4 shadow-2xl ring-1 ring-foreground/5 backdrop-blur-sm">
              <div className="flex items-start gap-3">
                <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
                  <LinkSimpleIcon className="size-5" weight="duotone" />
                </div>
                <div className="space-y-1">
                  <div className="text-sm font-medium text-foreground">
                    {t("app.groups.members.steam.preview.title")}
                  </div>
                  <p className="text-sm text-muted-foreground">{t("app.groups.members.steam.preview.description")}</p>
                </div>
              </div>
              <div className="pt-4">
                <Button
                  type="button"
                  size="sm"
                  onClick={() => {
                    setPreviewOpen(false);
                    setDialogOpen(true);
                  }}
                >
                  <LinkSimpleIcon data-icon="inline-start" />
                  {t("app.groups.members.actions.bindSteam")}
                </Button>
              </div>
            </div>
          )}
        </HoverCardContent>
      </HoverCard>

      {canManageSteam ? (
        <BindMemberSteamDialog groupId={groupId} member={member} open={dialogOpen} onOpenChange={setDialogOpen} />
      ) : null}
    </>
  );
};
