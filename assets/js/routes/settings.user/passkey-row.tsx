import { CheckIcon, FingerprintIcon, PencilSimpleIcon, XIcon } from "@phosphor-icons/react";
import type { FormEvent } from "react";
import { useTranslation } from "react-i18next";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { TableCell, TableRow } from "@/components/ui/table";
import { formatSettingsDate } from "@/routes/settings.user/format-date";
import { PasskeyDeleteDialog } from "@/routes/settings.user/passkey-delete-dialog";
import type { Passkey } from "@/routes/settings.user/types";

type PasskeyRowProps = {
  isEditing: boolean;
  onEditCancel: () => void;
  onEditStart: (id: number) => void;
  onInertSubmit: (event: FormEvent<HTMLFormElement>) => void;
  passkey: Passkey;
};

export const PasskeyRow = ({ isEditing, onEditCancel, onEditStart, onInertSubmit, passkey }: PasskeyRowProps) => {
  const { t } = useTranslation();

  return (
    <TableRow>
      <TableCell className="min-w-56">
        {isEditing ? (
          <form className="flex min-w-64 items-center gap-2" onSubmit={onInertSubmit}>
            <Input
              aria-label={t("app.settings.passkeys.rename.inputLabel")}
              defaultValue={passkey.label}
              name="label"
            />
            <Button type="submit" size="icon-sm">
              <CheckIcon />
              <span className="sr-only">{t("app.settings.passkeys.rename.save")}</span>
            </Button>
            <Button type="button" size="icon-sm" variant="ghost" onClick={onEditCancel}>
              <XIcon />
              <span className="sr-only">{t("app.settings.actions.cancel")}</span>
            </Button>
          </form>
        ) : (
          <div className="flex items-center gap-3">
            <span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-muted text-muted-foreground">
              <FingerprintIcon className="size-4" />
            </span>
            <div className="min-w-0">
              <div className="truncate font-medium">{passkey.label}</div>
              <div className="text-xs text-muted-foreground">
                {t("app.settings.passkeys.table.id", { id: passkey.id.toString() })}
              </div>
            </div>
          </div>
        )}
      </TableCell>
      <TableCell>
        {passkey.last_used_at ? (
          formatSettingsDate(passkey.last_used_at)
        ) : (
          <Badge variant="outline">{t("app.settings.passkeys.neverUsed")}</Badge>
        )}
      </TableCell>
      <TableCell>{formatSettingsDate(passkey.inserted_at)}</TableCell>
      <TableCell>
        <div className="flex justify-end gap-1">
          <Button type="button" size="icon-sm" variant="ghost" onClick={() => onEditStart(passkey.id)}>
            <PencilSimpleIcon />
            <span className="sr-only">{t("app.settings.passkeys.rename.trigger")}</span>
          </Button>
          <PasskeyDeleteDialog passkey={passkey} />
        </div>
      </TableCell>
    </TableRow>
  );
};
