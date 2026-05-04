import { SpinnerGapIcon, TrashIcon } from "@phosphor-icons/react";
import { useState } from "react";
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
  disabled: boolean;
  isDeleting: boolean;
  onDelete: (id: number, onDeleted: () => void) => void;
  passkey: Passkey;
};

export const PasskeyDeleteDialog = ({ disabled, isDeleting, onDelete, passkey }: PasskeyDeleteDialogProps) => {
  const { t } = useTranslation();
  const [isOpen, setIsOpen] = useState(false);

  return (
    <AlertDialog open={isOpen} onOpenChange={setIsOpen}>
      <AlertDialogTrigger render={<Button type="button" size="icon-sm" variant="ghost" disabled={disabled} />}>
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
          <AlertDialogCancel disabled={isDeleting}>{t("app.settings.actions.cancel")}</AlertDialogCancel>
          <AlertDialogAction
            disabled={isDeleting}
            type="button"
            variant="destructive"
            onClick={() => onDelete(passkey.id, () => setIsOpen(false))}
          >
            {isDeleting ? <SpinnerGapIcon data-icon="inline-start" className="animate-spin" /> : null}
            {t("app.settings.passkeys.delete.submit")}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
};
