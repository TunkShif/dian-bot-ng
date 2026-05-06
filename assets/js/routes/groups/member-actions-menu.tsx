import { DotsThreeIcon, LinkSimpleIcon } from "@phosphor-icons/react";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { BindMemberSteamDialog } from "@/routes/groups/bind-member-steam-dialog";
import type { GroupMember } from "@/routes/groups/types";

type MemberActionsMenuProps = {
  groupId: string;
  member: GroupMember;
};

export const MemberActionsMenu = ({ groupId, member }: MemberActionsMenuProps) => {
  const { t } = useTranslation();
  const [dialogOpen, setDialogOpen] = useState(false);

  return (
    <>
      <DropdownMenu>
        <DropdownMenuTrigger render={<Button type="button" size="icon-sm" variant="ghost" />}>
          <DotsThreeIcon />
          <span className="sr-only">{t("app.groups.members.actions.openMenu")}</span>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="min-w-44">
          <DropdownMenuItem onClick={() => setDialogOpen(true)}>
            <LinkSimpleIcon data-icon="inline-start" />
            {member.steam_player
              ? t("app.groups.members.actions.rebindSteam")
              : t("app.groups.members.actions.bindSteam")}
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>

      <BindMemberSteamDialog groupId={groupId} member={member} open={dialogOpen} onOpenChange={setDialogOpen} />
    </>
  );
};
