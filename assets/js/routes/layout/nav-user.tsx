import {
  BellIcon,
  CreditCardIcon,
  DotsThreeVerticalIcon,
  GlobeIcon,
  SignOutIcon,
  UserCircleIcon,
} from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuSub,
  DropdownMenuSubContent,
  DropdownMenuSubTrigger,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { SidebarMenu, SidebarMenuButton, SidebarMenuItem, useSidebar } from "@/components/ui/sidebar";
import { useLanguage } from "@/hooks/use-language";
import type { User } from "@/lib/user";

type NavUserProps = {
  user: User;
};

export function NavUser({ user }: NavUserProps) {
  const { t } = useTranslation();
  const { isMobile } = useSidebar();
  const { languages, currentLanguage, changeLanguage } = useLanguage();

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <DropdownMenu>
          <DropdownMenuTrigger render={<SidebarMenuButton size="lg" className="aria-expanded:bg-muted" />}>
            <Avatar className="size-8 rounded-lg grayscale">
              <AvatarImage src={user.avatar_url} alt={user.nickname} />
              <AvatarFallback className="rounded-lg">CN</AvatarFallback>
            </Avatar>
            <div className="grid flex-1 text-left text-sm leading-tight">
              <span className="truncate font-medium">{user.nickname}</span>
              <span className="truncate text-xs text-foreground/70">{user.qq_id}</span>
            </div>
            <DotsThreeVerticalIcon className="ml-auto size-4" />
          </DropdownMenuTrigger>
          <DropdownMenuContent className="min-w-56" side={isMobile ? "bottom" : "right"} align="end" sideOffset={4}>
            <DropdownMenuGroup>
              <DropdownMenuLabel className="p-0 font-normal">
                <div className="flex items-center gap-2 px-1 py-1.5 text-left text-sm">
                  <Avatar className="size-8">
                    <AvatarImage src={user.avatar_url} alt={user.nickname} />
                    <AvatarFallback className="rounded-lg">CN</AvatarFallback>
                  </Avatar>
                  <div className="grid flex-1 text-left text-sm leading-tight">
                    <span className="truncate font-medium">{user.nickname}</span>
                    <span className="truncate text-xs text-muted-foreground">{user.qq_id}</span>
                  </div>
                </div>
              </DropdownMenuLabel>
            </DropdownMenuGroup>
            <DropdownMenuSeparator />
            <DropdownMenuGroup>
              <DropdownMenuItem>
                <UserCircleIcon />
                {t("app.userMenu.account")}
              </DropdownMenuItem>
              <DropdownMenuItem>
                <CreditCardIcon />
                {t("app.userMenu.billing")}
              </DropdownMenuItem>
              <DropdownMenuItem>
                <BellIcon />
                {t("app.userMenu.notifications")}
              </DropdownMenuItem>
            </DropdownMenuGroup>
            <DropdownMenuSeparator />
            <DropdownMenuSub>
              <DropdownMenuSubTrigger aria-label={t("app.languageSwitch.label")}>
                <GlobeIcon />
                {t("app.languageSwitch.label")}
              </DropdownMenuSubTrigger>
              <DropdownMenuSubContent className="min-w-36">
                <DropdownMenuRadioGroup value={currentLanguage} onValueChange={changeLanguage}>
                  {languages.map((language) => (
                    <DropdownMenuRadioItem key={language.code} value={language.code}>
                      {language.label}
                    </DropdownMenuRadioItem>
                  ))}
                </DropdownMenuRadioGroup>
              </DropdownMenuSubContent>
            </DropdownMenuSub>
            <DropdownMenuSeparator />
            <DropdownMenuItem>
              <SignOutIcon />
              {t("app.userMenu.logOut")}
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </SidebarMenuItem>
    </SidebarMenu>
  );
}
