import { useTranslation } from "react-i18next";
import { Separator } from "@/components/ui/separator";
import { SidebarTrigger } from "@/components/ui/sidebar";
import { usePageTitle } from "@/hooks/use-page-title";

export function SiteHeader() {
  const { t } = useTranslation();
  const pageTitle = usePageTitle();

  return (
    <header className="flex h-(--header-height) shrink-0 items-center gap-2 border-b transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-(--header-height)">
      <div className="flex w-full items-center gap-1 px-4 lg:gap-2 lg:px-6">
        <SidebarTrigger className="-ml-1" srLabel={t("app.sidebar.toggleSidebar")} />
        <Separator orientation="vertical" className="mx-2 h-4 data-vertical:self-auto" />
        <h1 className="text-base font-medium">{pageTitle ?? t("app.brandName")}</h1>
      </div>
    </header>
  );
}
