import { CheckIcon, FingerprintIcon, PencilSimpleIcon, SpinnerGapIcon, XIcon } from "@phosphor-icons/react";
import type { KeyboardEvent, SubmitEvent } from "react";
import { useEffect, useRef, useState } from "react";
import { useTranslation } from "react-i18next";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { TableCell, TableRow } from "@/components/ui/table";
import { PasskeyDeleteDialog } from "@/routes/settings.user/passkey-delete-dialog";
import type { Passkey } from "@/routes/settings.user/types";
import { formatSettingsDate } from "@/routes/settings.user/utils";

type PasskeyRowProps = {
  disableDelete: boolean;
  disableRename: boolean;
  isDeleting: boolean;
  isEditing: boolean;
  isUpdating: boolean;
  onDeletePasskey: (id: number, onDeleted: () => void) => void;
  onEditCancel: () => void;
  onEditStart: (id: number) => void;
  onUpdatePasskey: (id: number, label: string) => void;
  passkey: Passkey;
};

export const PasskeyRow = ({
  disableDelete,
  disableRename,
  isDeleting,
  isEditing,
  isUpdating,
  onDeletePasskey,
  onEditCancel,
  onEditStart,
  onUpdatePasskey,
  passkey,
}: PasskeyRowProps) => {
  const { t } = useTranslation();
  const inputRef = useRef<HTMLInputElement>(null);
  const [label, setLabel] = useState(passkey.label);
  const [showValidation, setShowValidation] = useState(false);
  const trimmedLabel = label.trim();
  const isLabelEmpty = trimmedLabel.length === 0;

  useEffect(() => {
    if (!isEditing) {
      setLabel(passkey.label);
      setShowValidation(false);
      return;
    }

    setLabel(passkey.label);
    setShowValidation(false);
    requestAnimationFrame(() => {
      inputRef.current?.focus();
      inputRef.current?.select();
    });
  }, [isEditing, passkey.label]);

  const handleSubmit = (event: SubmitEvent<HTMLFormElement>) => {
    event.preventDefault();

    if (isLabelEmpty) {
      setShowValidation(true);
      inputRef.current?.focus();
      return;
    }

    onUpdatePasskey(passkey.id, trimmedLabel);
  };

  const handleKeyDown = (event: KeyboardEvent<HTMLInputElement>) => {
    if (event.key === "Escape") {
      event.preventDefault();
      onEditCancel();
    }
  };

  return (
    <TableRow>
      <TableCell className="min-w-56">
        {isEditing ? (
          <form className="grid min-w-64 gap-1.5" onSubmit={handleSubmit}>
            <div className="flex items-center gap-2">
              <Input
                aria-describedby={showValidation && isLabelEmpty ? `passkey-${passkey.id}-label-error` : undefined}
                aria-invalid={showValidation && isLabelEmpty}
                aria-label={t("app.settings.passkeys.rename.inputLabel")}
                disabled={isUpdating}
                name="label"
                onChange={(event) => {
                  setLabel(event.target.value);
                  if (event.target.value.trim()) {
                    setShowValidation(false);
                  }
                }}
                onKeyDown={handleKeyDown}
                ref={inputRef}
                value={label}
              />
              <Button type="submit" size="icon-sm" disabled={isUpdating || isLabelEmpty}>
                {isUpdating ? <SpinnerGapIcon className="animate-spin" /> : <CheckIcon />}
                <span className="sr-only">{t("app.settings.passkeys.rename.save")}</span>
              </Button>
              <Button type="button" size="icon-sm" variant="ghost" disabled={isUpdating} onClick={onEditCancel}>
                <XIcon />
                <span className="sr-only">{t("app.settings.actions.cancel")}</span>
              </Button>
            </div>
            {showValidation && isLabelEmpty ? (
              <p id={`passkey-${passkey.id}-label-error`} className="px-3 text-xs text-destructive">
                {t("app.settings.passkeys.rename.validation.required")}
              </p>
            ) : null}
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
          <Button
            type="button"
            size="icon-sm"
            variant="ghost"
            disabled={disableRename}
            onClick={() => onEditStart(passkey.id)}
          >
            <PencilSimpleIcon />
            <span className="sr-only">{t("app.settings.passkeys.rename.trigger")}</span>
          </Button>
          <PasskeyDeleteDialog
            disabled={disableDelete}
            isDeleting={isDeleting}
            onDelete={onDeletePasskey}
            passkey={passkey}
          />
        </div>
      </TableCell>
    </TableRow>
  );
};
