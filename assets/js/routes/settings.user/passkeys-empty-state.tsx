import { FingerprintIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import { Empty, EmptyDescription, EmptyHeader, EmptyMedia, EmptyTitle } from "@/components/ui/empty";

export const PasskeysEmptyState = () => {
  const { t } = useTranslation();

  return (
    <Empty className="border border-dashed">
      <EmptyHeader>
        <EmptyMedia variant="icon">
          <FingerprintIcon />
        </EmptyMedia>
        <EmptyTitle>{t("app.settings.passkeys.empty.title")}</EmptyTitle>
        <EmptyDescription>{t("app.settings.passkeys.empty.description")}</EmptyDescription>
      </EmptyHeader>
    </Empty>
  );
};
