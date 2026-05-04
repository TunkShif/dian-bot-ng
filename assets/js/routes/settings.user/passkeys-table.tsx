import type { FormEvent } from "react";
import { useTranslation } from "react-i18next";
import { Table, TableBody, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { PasskeyRow } from "@/routes/settings.user/passkey-row";
import type { Passkey } from "@/routes/settings.user/types";

type PasskeysTableProps = {
  editingPasskeyId: number | null;
  onEditCancel: () => void;
  onEditStart: (id: number) => void;
  onInertSubmit: (event: FormEvent<HTMLFormElement>) => void;
  passkeys: Passkey[];
};

export const PasskeysTable = ({
  editingPasskeyId,
  onEditCancel,
  onEditStart,
  onInertSubmit,
  passkeys,
}: PasskeysTableProps) => {
  const { t } = useTranslation();

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
        {passkeys.map((passkey) => (
          <PasskeyRow
            isEditing={editingPasskeyId === passkey.id}
            key={passkey.id}
            onEditCancel={onEditCancel}
            onEditStart={onEditStart}
            onInertSubmit={onInertSubmit}
            passkey={passkey}
          />
        ))}
      </TableBody>
    </Table>
  );
};
