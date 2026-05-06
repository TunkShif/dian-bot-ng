import { ArrowSquareOutIcon, GameControllerIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Badge } from "@/components/ui/badge";
import type { SteamPlayerSummary } from "@/lib/steam";

type PlayerState = SteamPlayerSummary["state"];

const stateVariantMap: Record<PlayerState, "default" | "secondary" | "destructive" | "outline"> = {
  online: "default",
  busy: "destructive",
  away: "secondary",
  snooze: "secondary",
  offline: "outline",
};

const useStateLabel = (state: PlayerState) => {
  const { t } = useTranslation();

  switch (state) {
    case "online":
      return t("app.settings.steam.state.online");
    case "busy":
      return t("app.settings.steam.state.busy");
    case "away":
      return t("app.settings.steam.state.away");
    case "snooze":
      return t("app.settings.steam.state.snooze");
    case "offline":
      return t("app.settings.steam.state.offline");
  }
};

export const SteamPlayerSummaryCard = ({ player }: { player: SteamPlayerSummary }) => {
  const { t } = useTranslation();
  const stateLabel = useStateLabel(player.state);
  const stateVariant = stateVariantMap[player.state];

  return (
    <div className="flex items-start gap-4 rounded-lg border border-border/70 bg-linear-to-br from-[#1b2838] via-[#1f2f43] to-[#171d25] p-4 text-primary-foreground shadow-sm">
      <div className="relative size-20 shrink-0 overflow-hidden rounded-md border border-white/10 bg-black/20 shadow-[inset_0_1px_0_rgba(255,255,255,0.05)]">
        <img src={player.avatar_url} alt={player.name} className="size-full object-cover" />
        <div className="pointer-events-none absolute inset-x-0 bottom-0 h-8 bg-linear-to-t from-black/35 to-transparent" />
      </div>
      <div className="flex min-w-0 flex-1 flex-col gap-1.5">
        <div className="flex flex-wrap items-center gap-2">
          <span className="truncate text-base font-semibold text-white">{player.name}</span>
          <Badge variant={stateVariant} className="border-white/10 bg-white/10 text-white hover:bg-white/10">
            {stateLabel}
          </Badge>
        </div>
        <a
          href={player.profile_url}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex max-w-fit items-center gap-1.5 text-sm font-medium text-[#9fd3ff] transition-colors hover:text-white"
        >
          <span>{t("app.settings.steam.profileLink")}</span>
          <ArrowSquareOutIcon className="size-4 shrink-0" />
        </a>
        {player.playing_game_name && (
          <div className="mt-1 inline-flex max-w-full items-center gap-2 rounded-md border border-[#66c0f4]/20 bg-[#66c0f4]/10 px-3 py-2 text-sm text-white/90">
            <GameControllerIcon className="size-4 shrink-0 text-[#66c0f4]" weight="fill" />
            <span className="truncate">{t("app.settings.steam.playing", { game: player.playing_game_name })}</span>
          </div>
        )}
      </div>
    </div>
  );
};
