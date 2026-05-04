import { useEffect } from "react";
import { useTranslation } from "react-i18next";
import { type LoaderFunctionArgs, Outlet, useLoaderData, useNavigate } from "react-router-dom";
import { toast } from "sonner";

type Flash = "welcome" | "logout" | "set_password";

type RootLoaderData = {
  flash: Flash | null;
};

export const loader = async ({ request }: LoaderFunctionArgs) => {
  const searchParams = new URL(request.url).searchParams;
  const flash = searchParams.get("flash");
  return {
    flash,
  };
};

export const Component = () => {
  const { flash } = useLoaderData<RootLoaderData>();
  const { t } = useTranslation();
  const navigate = useNavigate();

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
      default:
        return;
    }

    return () => {
      toast.dismiss(id);
    };
  }, [flash, navigate, t]);

  return <Outlet />;
};
