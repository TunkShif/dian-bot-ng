import { CaretDownIcon } from "@phosphor-icons/react";
import { useCallback, useState } from "react";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "@/components/ui/collapsible";
import {
  SidebarGroup,
  SidebarGroupContent,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarMenuSub,
  SidebarMenuSubButton,
  SidebarMenuSubItem,
} from "@/components/ui/sidebar";
import type { NavigationItem } from "@/menu";
import { type NavMenuExpansionState, setStoredNavMenuExpansionState } from "@/routes/layout/sidebar-storage";

export function NavMain({
  initialOpenState,
  items,
}: {
  initialOpenState: NavMenuExpansionState;
  items: NavigationItem[];
}) {
  const { t } = useTranslation();
  const [openState, setOpenState] = useState(initialOpenState);

  const handleOpenChange = useCallback((titleKey: NavigationItem["titleKey"], open: boolean) => {
    setOpenState((currentOpenState) => {
      const nextOpenState = {
        ...currentOpenState,
        [titleKey]: open,
      };

      setStoredNavMenuExpansionState(window.localStorage, nextOpenState);
      return nextOpenState;
    });
  }, []);

  return (
    <SidebarGroup>
      <SidebarGroupContent>
        <SidebarMenu>
          {items.map((item) => {
            const title = t(item.titleKey);

            if (!item.items?.length) {
              return (
                <SidebarMenuItem key={item.titleKey}>
                  <SidebarMenuButton tooltip={title} render={<Link to={item.url} />}>
                    {item.icon}
                    <span>{title}</span>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              );
            }

            const open = openState[item.titleKey] ?? true;

            return (
              <Collapsible
                key={item.titleKey}
                onOpenChange={(open) => handleOpenChange(item.titleKey, open)}
                open={open}
                render={<SidebarMenuItem />}
              >
                <CollapsibleTrigger render={<SidebarMenuButton tooltip={title} />}>
                  {item.icon}
                  <span>{title}</span>
                  <CaretDownIcon className="ml-auto transition-transform group-aria-expanded/menu-button:rotate-180" />
                </CollapsibleTrigger>
                <CollapsibleContent>
                  <SidebarMenuSub>
                    {item.items.map((child) => (
                      <SidebarMenuSubItem key={child.titleKey}>
                        <SidebarMenuSubButton render={<a href={child.url} />}>
                          {child.icon}
                          <span>{t(child.titleKey)}</span>
                        </SidebarMenuSubButton>
                      </SidebarMenuSubItem>
                    ))}
                  </SidebarMenuSub>
                </CollapsibleContent>
              </Collapsible>
            );
          })}
        </SidebarMenu>
      </SidebarGroupContent>
    </SidebarGroup>
  );
}
