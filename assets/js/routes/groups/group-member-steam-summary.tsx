import { SteamLogoIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import type { GroupMember } from "@/routes/groups/types";

type GroupMemberSteamSummaryProps = {
  steamPlayer: GroupMember["steam_player"];
};

export const GroupMemberSteamSummary = ({ steamPlayer }: GroupMemberSteamSummaryProps) => {
  const { t } = useTranslation();

  if (!steamPlayer) {
    return <span className="text-sm text-muted-foreground">{t("app.groups.members.steam.notLinked")}</span>;
  }

  return (
    <div className="flex min-w-0 items-center gap-2 text-sm text-foreground">
      <SteamLogoIcon className="size-4 shrink-0 text-[#66c0f4]" weight="duotone" />
      <span className="truncate">{steamPlayer.display_name || t("app.groups.members.steam.linked")}</span>
    </div>
  );
};
