import { FingerprintIcon, PlusIcon } from "@phosphor-icons/react";
import { type FormEvent, useId } from "react";
import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Field, FieldDescription, FieldGroup, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";

type AddPasskeyDialogProps = {
  onInertSubmit: (event: FormEvent<HTMLFormElement>) => void;
};

export const AddPasskeyDialog = ({ onInertSubmit }: AddPasskeyDialogProps) => {
  const { t } = useTranslation();
  const newPasskeyLabelId = useId();

  return (
    <Dialog>
      <DialogTrigger render={<Button type="button" />}>
        <PlusIcon data-icon="inline-start" />
        {t("app.settings.passkeys.add")}
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{t("app.settings.passkeys.addDialog.title")}</DialogTitle>
          <DialogDescription>{t("app.settings.passkeys.addDialog.description")}</DialogDescription>
        </DialogHeader>
        <form onSubmit={onInertSubmit}>
          <FieldGroup>
            <Field>
              <FieldLabel htmlFor={newPasskeyLabelId}>{t("app.settings.passkeys.addDialog.label")}</FieldLabel>
              <Input
                id={newPasskeyLabelId}
                name="label"
                placeholder={t("app.settings.passkeys.addDialog.placeholder")}
              />
              <FieldDescription>{t("app.settings.passkeys.addDialog.helper")}</FieldDescription>
            </Field>
            <DialogFooter>
              <DialogClose render={<Button type="button" variant="outline" />}>
                {t("app.settings.actions.cancel")}
              </DialogClose>
              <Button type="submit">
                <FingerprintIcon data-icon="inline-start" />
                {t("app.settings.passkeys.addDialog.submit")}
              </Button>
            </DialogFooter>
          </FieldGroup>
        </form>
      </DialogContent>
    </Dialog>
  );
};
