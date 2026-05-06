import { useTranslation } from "react-i18next";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
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
    <div className="flex items-start gap-4 rounded-lg border p-4">
      <Avatar size="lg">
        <AvatarImage src={player.avatar_url} alt={player.name} />
        <AvatarFallback>{player.name.slice(0, 2).toUpperCase()}</AvatarFallback>
      </Avatar>
      <div className="flex min-w-0 flex-1 flex-col gap-1.5">
        <div className="flex items-center gap-2">
          <span className="truncate font-medium">{player.name}</span>
          <Badge variant={stateVariant}>{stateLabel}</Badge>
        </div>
        <a
          href={player.profile_url}
          target="_blank"
          rel="noopener noreferrer"
          className="truncate text-sm text-muted-foreground hover:text-foreground hover:underline transition-colors"
        >
          {player.steam_id}
        </a>
        {player.playing_game_name && (
          <p className="text-sm text-muted-foreground">
            {t("app.settings.steam.playing", { game: player.playing_game_name })}
          </p>
        )}
      </div>
    </div>
  );
};
