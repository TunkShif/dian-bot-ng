import { NotebookIcon } from "@phosphor-icons/react";
import type * as React from "react";
import { useTranslation } from "react-i18next";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { useCurrentUser } from "@/hooks/use-current-user";
import { navigationMenu } from "@/menu";
import { NavMain } from "@/routes/layout/nav-main";
import { NavUser } from "@/routes/layout/nav-user";
import type { NavMenuExpansionState } from "@/routes/layout/sidebar-storage";

type AppSidebarProps = React.ComponentProps<typeof Sidebar> & {
  navMenuExpansionState: NavMenuExpansionState;
};

export function AppSidebar({ navMenuExpansionState, ...props }: AppSidebarProps) {
  const { t } = useTranslation();
  const currentUser = useCurrentUser();

  return (
    <Sidebar collapsible="offcanvas" {...props}>
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton className="data-[slot=sidebar-menu-button]:p-1.5!" render={<a href="/dashboard" />}>
              <NotebookIcon className="size-5!" />
              <span className="text-base font-semibold">{t("app.brandName")}</span>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
        <NavMain initialOpenState={navMenuExpansionState} items={navigationMenu} />
      </SidebarContent>
      <SidebarFooter>{currentUser ? <NavUser user={currentUser} /> : null}</SidebarFooter>
    </Sidebar>
  );
}
