import { Outlet, redirect } from "react-router-dom";
import { toast } from "sonner";
import { getCurrentUserOptions } from "@/client/@tanstack/react-query.gen";
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar";
import { queryClient } from "@/lib/query-client";
import { AppSidebar } from "@/routes/layout/app-sidebar";
import { SectionCards } from "@/routes/layout/section-cards";
import { SiteHeader } from "@/routes/layout/site-header";

export const loader = async () => {
  const response = await queryClient.fetchQuery(getCurrentUserOptions());
  if (!response.data.user) {
    toast.error("you must login first");
    return redirect("/login");
  }
  return {};
};

export const Component = () => {
  return (
    <SidebarProvider
      style={
        {
          "--sidebar-width": "calc(var(--spacing) * 72)",
          "--header-height": "calc(var(--spacing) * 12)",
        } as React.CSSProperties
      }
    >
      <AppSidebar variant="inset" />
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
