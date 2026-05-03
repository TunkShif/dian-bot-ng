import { CaretDownIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
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

export function NavMain({ items }: { items: NavigationItem[] }) {
  const { t } = useTranslation();

  return (
    <SidebarGroup>
      <SidebarGroupContent>
        <SidebarMenu>
          {items.map((item) => {
            const title = t(item.titleKey);

            if (!item.items?.length) {
              return (
                <SidebarMenuItem key={item.titleKey}>
                  <SidebarMenuButton tooltip={title} render={<a href={item.url} />}>
                    {item.icon}
                    <span>{title}</span>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              );
            }

            return (
              <Collapsible key={item.titleKey} defaultOpen render={<SidebarMenuItem />}>
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
