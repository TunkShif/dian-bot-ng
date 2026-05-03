import {
  ChartBarIcon,
  ChartLineIcon,
  DatabaseIcon,
  FileIcon,
  FolderIcon,
  GearIcon,
  ListIcon,
  MagnifyingGlassIcon,
  NotebookIcon,
  QuestionIcon,
  SquaresFourIcon,
  UsersIcon,
} from "@phosphor-icons/react";
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
import { NavDocuments } from "@/routes/layout/nav-documents";
import { NavMain } from "@/routes/layout/nav-main";
import { NavSecondary } from "@/routes/layout/nav-secondary";
import { NavUser } from "@/routes/layout/nav-user";

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
  const { t } = useTranslation();
  const data = {
    user: {
      name: "shadcn",
      email: "m@example.com",
      avatar: "/avatars/shadcn.jpg",
    },
    navMain: [
      {
        title: t("app.nav.dashboard"),
        url: "#",
        icon: <SquaresFourIcon />,
      },
      {
        title: t("app.nav.lifecycle"),
        url: "#",
        icon: <ListIcon />,
      },
      {
        title: t("app.nav.analytics"),
        url: "#",
        icon: <ChartBarIcon />,
      },
      {
        title: t("app.nav.projects"),
        url: "#",
        icon: <FolderIcon />,
      },
      {
        title: t("app.nav.team"),
        url: "#",
        icon: <UsersIcon />,
      },
    ],
    navSecondary: [
      {
        title: t("app.nav.settings"),
        url: "#",
        icon: <GearIcon />,
      },
      {
        title: t("app.nav.help"),
        url: "#",
        icon: <QuestionIcon />,
      },
      {
        title: t("app.nav.search"),
        url: "#",
        icon: <MagnifyingGlassIcon />,
      },
    ],
    documents: [
      {
        name: t("app.nav.dataLibrary"),
        url: "#",
        icon: <DatabaseIcon />,
      },
      {
        name: t("app.nav.reports"),
        url: "#",
        icon: <ChartLineIcon />,
      },
      {
        name: t("app.nav.wordAssistant"),
        url: "#",
        icon: <FileIcon />,
      },
    ],
  };

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
        <NavMain items={data.navMain} />
        <NavDocuments items={data.documents} />
        <NavSecondary items={data.navSecondary} className="mt-auto" />
      </SidebarContent>
      <SidebarFooter>
        <NavUser user={data.user} />
      </SidebarFooter>
    </Sidebar>
  );
}
