import { useTranslation } from "react-i18next";
import { Table, TableBody, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { PasskeyRow } from "@/routes/settings.user/passkey-row";
import type { Passkey } from "@/routes/settings.user/types";

type PasskeysTableProps = {
  deletingPasskeyId: number | null;
  editingPasskeyId: number | null;
  updatingPasskeyId: number | null;
  onDeletePasskey: (id: number, onDeleted: () => void) => void;
  onEditCancel: () => void;
  onEditStart: (id: number) => void;
  onUpdatePasskey: (id: number, label: string) => void;
  passkeys: Passkey[];
};

export const PasskeysTable = ({
  deletingPasskeyId,
  editingPasskeyId,
  updatingPasskeyId,
  onDeletePasskey,
  onEditCancel,
  onEditStart,
  onUpdatePasskey,
  passkeys,
}: PasskeysTableProps) => {
  const { t } = useTranslation();
  const isDeletePending = deletingPasskeyId !== null;
  const isRenamePending = updatingPasskeyId !== null;
  const isMutationPending = isDeletePending || isRenamePending;

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>{t("app.settings.passkeys.table.name")}</TableHead>
          <TableHead>{t("app.settings.passkeys.table.lastUsed")}</TableHead>
          <TableHead>{t("app.settings.passkeys.table.created")}</TableHead>
          <TableHead className="w-28 text-right">{t("app.settings.passkeys.table.actions")}</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {passkeys.map((passkey) => {
          const isEditing = editingPasskeyId === passkey.id;
          const isUpdating = updatingPasskeyId === passkey.id;

          return (
            <PasskeyRow
              disableDelete={isMutationPending}
              disableRename={isMutationPending || (editingPasskeyId !== null && !isEditing)}
              isDeleting={deletingPasskeyId === passkey.id}
              isEditing={isEditing}
              isUpdating={isUpdating}
              key={passkey.id}
              onDeletePasskey={onDeletePasskey}
              onEditCancel={onEditCancel}
              onEditStart={onEditStart}
              onUpdatePasskey={onUpdatePasskey}
              passkey={passkey}
            />
          );
        })}
      </TableBody>
    </Table>
  );
};
