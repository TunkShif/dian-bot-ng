import { MagnifyingGlassIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { EmptyState } from "@/routes/groups/empty-state";

export const GroupListEmpty = () => {
  const { t } = useTranslation();

  return (
    <EmptyState
      icon={<MagnifyingGlassIcon className="size-5" />}
      title={t("app.groups.list.empty.title")}
      description={t("app.groups.list.empty.description")}
    />
  );
};
