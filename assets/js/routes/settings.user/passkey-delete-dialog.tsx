import { TrashIcon } from "@phosphor-icons/react";
import { useTranslation } from "react-i18next";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { Button } from "@/components/ui/button";
import type { Passkey } from "@/routes/settings.user/types";

type PasskeyDeleteDialogProps = {
  passkey: Passkey;
};

export const PasskeyDeleteDialog = ({ passkey }: PasskeyDeleteDialogProps) => {
  const { t } = useTranslation();

  return (
    <AlertDialog>
      <AlertDialogTrigger render={<Button type="button" size="icon-sm" variant="ghost" />}>
        <TrashIcon />
        <span className="sr-only">{t("app.settings.passkeys.delete.trigger")}</span>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{t("app.settings.passkeys.delete.title")}</AlertDialogTitle>
          <AlertDialogDescription>
            {t("app.settings.passkeys.delete.description", { label: passkey.label })}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>{t("app.settings.actions.cancel")}</AlertDialogCancel>
          <AlertDialogAction type="button" variant="destructive">
            {t("app.settings.passkeys.delete.submit")}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
};
