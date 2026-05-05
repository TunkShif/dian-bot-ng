import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { cn } from "@/lib/utils";
import type { GroupListItem } from "@/routes/groups/types";
import { getAvatarFallback } from "@/routes/groups/utils";

type GroupAvatarProps = {
  group: Pick<GroupListItem, "avatar_url" | "group_name" | "enabled">;
  size?: "default" | "lg";
};

export const GroupAvatar = ({ group, size = "default" }: GroupAvatarProps) => (
  <Avatar size={size} className={cn(!group.enabled && "opacity-60 grayscale")}>
    <AvatarImage src={group.avatar_url} alt="" />
    <AvatarFallback>{getAvatarFallback(group.group_name)}</AvatarFallback>
  </Avatar>
);
