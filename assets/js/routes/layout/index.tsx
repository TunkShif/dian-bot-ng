import { ArrowLeftIcon, HouseIcon, WarningOctagonIcon } from "@phosphor-icons/react";
import type * as React from "react";
import { useTranslation } from "react-i18next";
import { Link, Outlet, redirect, useLoaderData, useNavigate, useRouteError } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar";
import { formatRouteErrorDetails, getRouteErrorTranslationKeys } from "@/lib/route-error";
import { getCurrentUser } from "@/lib/user";
import { AppSidebar } from "@/routes/layout/app-sidebar";
import { getStoredNavMenuExpansionState, type NavMenuExpansionState } from "@/routes/layout/sidebar-storage";
import { SiteHeader } from "@/routes/layout/site-header";

type LayoutLoaderData = {
  navMenuExpansionState: NavMenuExpansionState;
};

export const loader = async () => {
  const user = await getCurrentUser();
  if (!user) {
    return redirect("/login?flash=auth_required");
  }

  const navMenuExpansionState =
    typeof window === "undefined" ? {} : getStoredNavMenuExpansionState(window.localStorage);

  return { navMenuExpansionState };
};

export const Component = () => {
  const { navMenuExpansionState } = useLoaderData<LayoutLoaderData>();

  return (
    <AppShell navMenuExpansionState={navMenuExpansionState}>
      <Outlet />
    </AppShell>
  );
};

export function ErrorBoundary() {
  const error = useRouteError();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const { titleKey, descriptionKey } = getRouteErrorTranslationKeys(error);
  const errorDetails = formatRouteErrorDetails(error);

  return (
    <AppShell navMenuExpansionState={getFallbackNavMenuExpansionState()} contentClassName="min-h-0 flex-1 py-0">
      <div className="mx-auto flex min-h-0 flex-1 items-center px-4 py-6 md:px-6">
        <section className="w-full overflow-hidden rounded-xl border border-border/70 bg-background shadow-xl shadow-foreground/5">
          <div className="relative border-b border-border/70 bg-muted/40 px-6 py-8 sm:px-8">
            <div
              aria-hidden="true"
              className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_18%_0%,color-mix(in_oklch,var(--primary)_10%,transparent),transparent_54%)]"
            />
            <div className="relative flex items-start gap-4">
              <div className="flex size-12 shrink-0 items-center justify-center rounded-xl bg-destructive/10 text-destructive ring-1 ring-destructive/15">
                <WarningOctagonIcon className="size-6" weight="duotone" />
              </div>
              <div className="min-w-0 space-y-2">
                <p className="text-sm font-medium text-muted-foreground">{t("app.errorBoundary.eyebrow")}</p>
                <h1 className="text-2xl font-semibold tracking-normal text-balance text-foreground">{t(titleKey)}</h1>
                <p className="text-sm leading-6 text-muted-foreground">{t(descriptionKey)}</p>
              </div>
            </div>
          </div>
          <div className="space-y-5 px-6 py-6 sm:px-8">
            <div>
              <p className="mb-2 text-xs font-medium tracking-normal text-muted-foreground uppercase">
                {t("app.errorBoundary.details")}
              </p>
              <pre className="max-h-32 overflow-hidden rounded-lg border border-border/70 bg-muted/60 px-3 py-2 text-left shadow-inner shadow-foreground/5">
                <code className="block font-mono text-[0.75rem] leading-5 whitespace-pre-wrap text-muted-foreground">
                  {errorDetails}
                </code>
              </pre>
            </div>
            <div className="flex flex-col gap-3 sm:flex-row">
              <Button type="button" onClick={() => navigate(-1)}>
                <ArrowLeftIcon className="size-4" />
                {t("app.errorBoundary.goBack")}
              </Button>
              <Button type="button" variant="outline" render={<Link to="/dashboard" />}>
                <HouseIcon className="size-4" />
                {t("app.errorBoundary.dashboard")}
              </Button>
            </div>
          </div>
        </section>
      </div>
    </AppShell>
  );
}

type AppShellProps = {
  navMenuExpansionState: NavMenuExpansionState;
  children: React.ReactNode;
  contentClassName?: string;
};

const AppShell = ({ navMenuExpansionState, children, contentClassName = "py-4 md:py-6" }: AppShellProps) => {
  return (
    <SidebarProvider
      className="h-svh overflow-hidden"
      style={
        {
          "--sidebar-width": "calc(var(--spacing) * 72)",
          "--header-height": "calc(var(--spacing) * 12)",
        } as React.CSSProperties
      }
    >
      <AppSidebar navMenuExpansionState={navMenuExpansionState} variant="inset" />
      <SidebarInset className="min-w-0 overflow-hidden">
        <SiteHeader />

        <div className="flex min-h-0 flex-1 flex-col overflow-y-auto overscroll-contain">
          <div className="@container/main flex min-h-0 flex-1 flex-col gap-2">
            <div className={`flex min-h-0 flex-1 flex-col gap-4 md:gap-6 ${contentClassName}`}>{children}</div>
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>
  );
};

const getFallbackNavMenuExpansionState = () => {
  return typeof window === "undefined" ? {} : getStoredNavMenuExpansionState(window.localStorage);
};
