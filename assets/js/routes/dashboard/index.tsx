import { useTranslation } from "react-i18next";

export const handle = { pageTitleKey: "app.dashboard.pageTitle" } as const;

export const Component = () => {
  const { t } = useTranslation();

  return <div>{t("app.dashboard.title")}</div>;
};
