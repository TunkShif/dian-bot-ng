import { GameControllerIcon, SpinnerGapIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import {
  HoverCard,
  HoverCardContent,
  HoverCardTrigger,
} from "@/components/ui/hover-card";
import { SteamPlayerSummaryCard } from "@/components/steam-player-summary-card";
import { useSteamPlayerLookup } from "@/lib/steam";
import type { GroupMember } from "@/routes/groups/types";
import { getAvatarFallback } from "@/routes/groups/utils";
import { cn } from "@/lib/utils";
import { useState } from "react";

const stateDotClass: Record<string, string> = {
  online: "bg-emerald-500",
  busy: "bg-red-500",
  away: "bg-amber-500",
  snooze: "bg-amber-500",
  offline: "bg-muted-foreground/40",
};

type SteamMemberRowProps = {
  groupId: string;
  member: GroupMember;
};

export const SteamMemberRow = ({ groupId, member }: SteamMemberRowProps) => {
  const { t } = useTranslation();
  const [previewOpen, setPreviewOpen] = useState(false);
  const steamPlayer = member.steam_player;

  const previewQuery = useSteamPlayerLookup(
    previewOpen && steamPlayer ? steamPlayer.steam_id : null
  );

  const state = previewQuery.data?.state;
  const isPlaying = !!previewQuery.data?.playing_game_name;
  const isOnline = state && state !== "offline";

  return (
    <HoverCard open={previewOpen} onOpenChange={setPreviewOpen}>
      <HoverCardTrigger
        delay={150}
        closeDelay={100}
        render={<button type="button" />}
        className={cn(
          "flex w-full min-w-0 items-center gap-3 rounded-lg px-3 py-2.5 text-left transition-colors",
          "hover:bg-accent/60 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
        )}
      >
        <div className="relative shrink-0">
          <Avatar className="size-8">
            <AvatarImage src={member.avatar_url} alt="" />
            <AvatarFallback className="text-xs">
              {getAvatarFallback(member.display_name || member.nickname)}
            </AvatarFallback>
          </Avatar>
          {state && (
            <span
              className={cn(
                "absolute -bottom-0.5 -right-0.5 size-3 rounded-full border-2 border-card",
                stateDotClass[state] ?? stateDotClass.offline
              )}
            />
          )}
        </div>
        <div className="min-w-0 flex-1">
          <div className="truncate text-sm font-medium text-foreground">
            {member.display_name || member.nickname}
          </div>
          {previewQuery.isLoading ? (
            <div className="flex items-center gap-1 text-xs text-muted-foreground">
              <SpinnerGapIcon className="size-3 animate-spin" />
              {t("app.monitor.loadingStatus")}
            </div>
          ) : isPlaying ? (
            <div className="flex items-center gap-1.5 text-xs text-[#66c0f4]">
              <GameControllerIcon className="size-3" weight="fill" />
              <span className="truncate">
                {previewQuery.data.playing_game_name}
              </span>
            </div>
          ) : (
            <div className="text-xs text-muted-foreground">
              {steamPlayer?.display_name}
            </div>
          )}
        </div>
        {state && !previewQuery.isLoading && (
          <Badge
            variant={isOnline ? "default" : "outline"}
            className={cn(
              "shrink-0 text-xs",
              isOnline && !isPlaying &&
                "bg-emerald-500/15 text-emerald-600 border-emerald-500/30 hover:bg-emerald-500/15",
              isPlaying &&
                "bg-[#66c0f4]/15 text-[#66c0f4] border-[#66c0f4]/30 hover:bg-[#66c0f4]/15"
            )}
          >
            {isPlaying
              ? t("app.monitor.state.playing")
              : t(`app.settings.steam.state.${state}`)}
          </Badge>
        )}
      </HoverCardTrigger>
      <HoverCardContent
        align="start"
        className="w-88 rounded-none bg-transparent p-0 shadow-none ring-0"
      >
        {previewQuery.isLoading ? (
          <div className="flex items-center justify-center rounded-2xl border border-border/70 bg-popover/95 p-8 text-muted-foreground shadow-2xl ring-1 ring-foreground/5 backdrop-blur-sm">
            <SpinnerGapIcon className="size-5 animate-spin" />
          </div>
        ) : previewQuery.isError ? (
          <div className="rounded-2xl border border-destructive/40 bg-popover/95 p-4 text-sm text-destructive shadow-2xl ring-1 ring-foreground/5 backdrop-blur-sm">
            {t("app.monitor.previewError")}
          </div>
        ) : previewQuery.data ? (
          <SteamPlayerSummaryCard player={previewQuery.data} />
        ) : null}
      </HoverCardContent>
    </HoverCard>
  );
};
