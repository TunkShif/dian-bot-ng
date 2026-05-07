import { ArrowLeftIcon, HouseIcon, NotebookIcon, SignInIcon, WarningOctagonIcon } from "@phosphor-icons/react";
import { useEffect } from "react";
import { Helmet } from "react-helmet-async";
import { useTranslation } from "react-i18next";
import {
  Link,
  type LoaderFunctionArgs,
  Outlet,
  useLoaderData,
  useNavigate,
  useNavigation,
  useRouteError,
} from "react-router-dom";
import { toast } from "sonner";
import topbar from "topbar";
import { Button } from "@/components/ui/button";
import { useCurrentUser } from "@/hooks/use-current-user";
import { usePageTitle } from "@/hooks/use-page-title";
import { formatRouteErrorDetails, getRouteErrorTranslationKeys } from "@/lib/route-error";

type Flash = "welcome" | "logout" | "set_password" | "auth_required";

type RootLoaderData = {
  flash: Flash | null;
};

export const loader = async ({ request }: LoaderFunctionArgs) => {
  const searchParams = new URL(request.url).searchParams;
  const flash = searchParams.get("flash");

  return {
    flash:
      flash === "welcome" || flash === "logout" || flash === "set_password" || flash === "auth_required" ? flash : null,
  };
};

export const Component = () => {
  const { flash } = useLoaderData<RootLoaderData>();
  const { t } = useTranslation();
  const navigate = useNavigate();
  const navigation = useNavigation();
  const pageTitle = usePageTitle();

  useEffect(() => {
    if (flash === null) return;

    let id: string | number;
    switch (flash) {
      case "welcome":
        id = toast(t("auth.flash.welcome"));
        break;
      case "logout":
        id = toast(t("auth.flash.logout"));
        break;
      case "set_password":
        id = toast(t("auth.flash.setPassword"), {
          description: t("auth.flash.setPasswordDescription"),
          action: {
            label: t("auth.flash.setPasswordAction"),
            onClick: () => {
              navigate("/settings/user");
            },
          },
        });
        break;
      case "auth_required":
        id = toast.error(t("app.auth.required"));
        break;
      default:
        return;
    }

    return () => {
      toast.dismiss(id);
    };
  }, [flash, navigate, t]);

  useEffect(() => {
    if (navigation.state === "loading") {
      topbar.show();
    } else {
      topbar.hide();
    }
    return () => {
      topbar.hide();
    };
  }, [navigation.state]);

  return (
    <>
      <Helmet defaultTitle={t("app.brandName")} titleTemplate={`%s | ${t("app.brandName")}`}>
        {pageTitle ? <title>{pageTitle}</title> : null}
      </Helmet>
      <Outlet />
    </>
  );
};

export function ErrorBoundary() {
  const error = useRouteError();
  const errorDetails = formatRouteErrorDetails(error);
  const { titleKey, descriptionKey } = getRouteErrorTranslationKeys(error);
  const user = useCurrentUser();
  const { t } = useTranslation();
  const navigate = useNavigate();
  const secondaryAction = user
    ? {
        to: "/dashboard",
        label: t("app.errorBoundary.dashboard"),
        icon: HouseIcon,
      }
    : {
        to: "/login",
        label: t("app.errorBoundary.login"),
        icon: SignInIcon,
      };
  const SecondaryActionIcon = secondaryAction.icon;

  return (
    <>
      <Helmet>
        <title>{t(titleKey)}</title>
      </Helmet>
      <div className="relative isolate flex min-h-svh items-center justify-center overflow-hidden bg-muted p-6 md:p-10">
        <div
          aria-hidden="true"
          className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_50%_32%,color-mix(in_oklch,var(--primary)_14%,transparent),transparent_58%),radial-gradient(ellipse_at_50%_100%,color-mix(in_oklch,var(--foreground)_7%,transparent),transparent_52%)]"
        />
        <div
          aria-hidden="true"
          className="pointer-events-none absolute inset-0 opacity-[0.24] bg-[linear-gradient(to_right,color-mix(in_oklch,var(--foreground)_10%,transparent)_1px,transparent_1px),linear-gradient(to_bottom,color-mix(in_oklch,var(--foreground)_10%,transparent)_1px,transparent_1px)] bg-size-[44px_44px]"
        />
        <div className="absolute top-5 left-5 z-20 flex items-center gap-2.5 rounded-full border border-border/70 bg-background/80 px-3 py-2 text-foreground shadow-lg shadow-foreground/5 backdrop-blur-md transition-colors md:top-8 md:left-8">
          <div className="flex size-8 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-sm shadow-primary/20">
            <NotebookIcon className="size-4.5" weight="bold" />
          </div>
          <span className="text-sm font-semibold whitespace-nowrap text-foreground/80 uppercase select-none">
            {t("app.brandName")}
          </span>
        </div>
        <section className="relative z-10 grid w-full max-w-4xl overflow-hidden rounded-2xl border border-border/70 bg-background/88 shadow-2xl shadow-foreground/8 backdrop-blur-xl md:grid-cols-[minmax(0,1fr)_18rem]">
          <div className="flex min-h-108 flex-col justify-center px-6 py-10 sm:px-10 md:px-12">
            <div className="mb-7 flex size-14 items-center justify-center rounded-2xl bg-destructive/10 text-destructive ring-1 ring-destructive/15">
              <WarningOctagonIcon className="size-7" weight="duotone" />
            </div>
            <div className="max-w-xl space-y-3">
              <p className="text-sm font-medium text-muted-foreground">{t("app.errorBoundary.eyebrow")}</p>
              <h1 className="text-3xl font-semibold tracking-normal text-balance text-foreground sm:text-4xl">
                {t(titleKey)}
              </h1>
              <p className="text-base leading-7 text-muted-foreground">{t(descriptionKey)}</p>
              <div className="pt-3">
                <p className="mb-2 text-xs font-medium tracking-normal text-muted-foreground uppercase">
                  {t("app.errorBoundary.details")}
                </p>
                <pre className="max-h-32 overflow-hidden rounded-lg border border-border/70 bg-muted/60 px-3 py-2 text-left shadow-inner shadow-foreground/5">
                  <code className="block font-mono text-[0.75rem] leading-5 whitespace-pre-wrap text-muted-foreground">
                    {errorDetails}
                  </code>
                </pre>
              </div>
            </div>
            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <Button type="button" onClick={() => navigate(-1)}>
                <ArrowLeftIcon className="size-4" />
                {t("app.errorBoundary.goBack")}
              </Button>
              <Button type="button" variant="outline" render={<Link to={secondaryAction.to} />} nativeButton={false}>
                <SecondaryActionIcon className="size-4" />
                {secondaryAction.label}
              </Button>
            </div>
          </div>
          <div className="relative hidden overflow-hidden bg-muted md:block">
            <img
              src="/images/abstract-wave-pattern-portrait-bg.webp"
              alt=""
              aria-hidden="true"
              className="absolute inset-0 h-full w-full object-cover dark:brightness-[0.62]"
            />
            <div
              aria-hidden="true"
              className="absolute inset-0 bg-[radial-gradient(circle_at_35%_20%,color-mix(in_oklch,var(--background)_22%,transparent),transparent_42%),linear-gradient(to_bottom,color-mix(in_oklch,var(--background)_8%,transparent),color-mix(in_oklch,var(--foreground)_20%,transparent))]"
            />
          </div>
        </section>
      </div>
    </>
  );
}
