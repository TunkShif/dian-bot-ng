import i18n from "i18next";
import { Outlet, redirect, useLoaderData } from "react-router-dom";
import { toast } from "sonner";
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar";
import { getCurrentUser } from "@/lib/user";
import { AppSidebar } from "@/routes/layout/app-sidebar";
import { SectionCards } from "@/routes/layout/section-cards";
import { getStoredNavMenuExpansionState, type NavMenuExpansionState } from "@/routes/layout/sidebar-storage";
import { SiteHeader } from "@/routes/layout/site-header";

type LayoutLoaderData = {
  navMenuExpansionState: NavMenuExpansionState;
};

export const loader = async () => {
  const user = await getCurrentUser();
  if (!user) {
    toast.error(i18n.t("app.auth.required"));
    return redirect("/login");
  }

  const navMenuExpansionState =
    typeof window === "undefined" ? {} : getStoredNavMenuExpansionState(window.localStorage);

  return { navMenuExpansionState };
};

export const Component = () => {
  const { navMenuExpansionState } = useLoaderData<LayoutLoaderData>();

  return (
    <SidebarProvider
      style={
        {
          "--sidebar-width": "calc(var(--spacing) * 72)",
          "--header-height": "calc(var(--spacing) * 12)",
        } as React.CSSProperties
      }
    >
      <AppSidebar navMenuExpansionState={navMenuExpansionState} variant="inset" />
      <SidebarInset>
        <SiteHeader />
        <Outlet />

        <div className="flex flex-1 flex-col">
          <div className="@container/main flex flex-1 flex-col gap-2">
            <div className="flex flex-col gap-4 py-4 md:gap-6 md:py-6">
              <SectionCards />
            </div>
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>
  );
};
