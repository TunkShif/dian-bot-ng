import { useTranslation } from "react-i18next";
import { useMatches } from "react-router-dom";

type RouteHandle = {
  pageTitleKey?: string;
};

export const usePageTitle = () => {
  const { t } = useTranslation();
  const matches = useMatches();

  const pageHandle = [...matches].reverse().find((match) => (match.handle as RouteHandle)?.pageTitleKey != null)
    ?.handle as RouteHandle | undefined;

  // biome-ignore lint/suspicious/noExplicitAny: satisfy the strictly typed t() function
  return pageHandle?.pageTitleKey ? t(pageHandle.pageTitleKey as any) : undefined;
};
