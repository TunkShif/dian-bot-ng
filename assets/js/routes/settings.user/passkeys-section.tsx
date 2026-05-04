import { FingerprintIcon } from "@phosphor-icons/react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import {
  deletePasskeyMutation,
  listPasskeysOptions,
  listPasskeysQueryKey,
  updatePasskeyMutation,
} from "@/client/@tanstack/react-query.gen";
import { Card, CardAction, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { AddPasskeyDialog } from "@/routes/settings.user/add-passkey-dialog";
import { PasskeysEmptyState } from "@/routes/settings.user/passkeys-empty-state";
import { PasskeysErrorState } from "@/routes/settings.user/passkeys-error-state";
import { PasskeysLoadingState } from "@/routes/settings.user/passkeys-loading-state";
import { PasskeysTable } from "@/routes/settings.user/passkeys-table";

export const PasskeysSection = () => {
  const { t } = useTranslation();
  const [deletingPasskeyId, setDeletingPasskeyId] = useState<number | null>(null);
  const [editingPasskeyId, setEditingPasskeyId] = useState<number | null>(null);
  const [updatingPasskeyId, setUpdatingPasskeyId] = useState<number | null>(null);
  const passkeysQuery = useQuery(listPasskeysOptions());
  const passkeys = passkeysQuery.data?.data.passkeys ?? [];

  const { mutate: updateMutate } = useMutation({
    ...updatePasskeyMutation(),
    meta: {
      invalidatesQuery: listPasskeysQueryKey(),
      successMessage: t("app.settings.passkeys.rename.successMessage"),
      errorMessage: t("app.settings.passkeys.rename.errorMessage"),
    },
  });

  const { mutate: deleteMutate } = useMutation({
    ...deletePasskeyMutation(),
    meta: {
      invalidatesQuery: listPasskeysQueryKey(),
      successMessage: t("app.settings.passkeys.delete.successMessage"),
      errorMessage: t("app.settings.passkeys.delete.errorMessage"),
    },
  });

  const handleUpdatePasskey = (id: number, label: string) => {
    if (updatingPasskeyId !== null) {
      return;
    }

    setUpdatingPasskeyId(id);
    updateMutate(
      { path: { id }, body: { label } },
      {
        onSuccess: () => setEditingPasskeyId(null),
        onSettled: () => setUpdatingPasskeyId(null),
      },
    );
  };

  const handleDeletePasskey = (id: number, onDeleted: () => void) => {
    if (deletingPasskeyId !== null || updatingPasskeyId !== null) {
      return;
    }

    setDeletingPasskeyId(id);
    deleteMutate(
      { path: { id } },
      {
        onSuccess: onDeleted,
        onSettled: () => setDeletingPasskeyId(null),
      },
    );
  };

  return (
    <Card>
      <CardHeader>
        <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
          <FingerprintIcon className="size-5" weight="duotone" />
        </div>
        <CardTitle>{t("app.settings.passkeys.title")}</CardTitle>
        <CardDescription>{t("app.settings.passkeys.description")}</CardDescription>
        <CardAction>
          <AddPasskeyDialog />
        </CardAction>
      </CardHeader>
      <CardContent>
        {passkeysQuery.isLoading ? <PasskeysLoadingState /> : null}
        {passkeysQuery.isError ? <PasskeysErrorState onRetry={() => void passkeysQuery.refetch()} /> : null}
        {passkeysQuery.isSuccess && passkeys.length === 0 ? <PasskeysEmptyState /> : null}
        {passkeysQuery.isSuccess && passkeys.length > 0 ? (
          <PasskeysTable
            deletingPasskeyId={deletingPasskeyId}
            editingPasskeyId={editingPasskeyId}
            updatingPasskeyId={updatingPasskeyId}
            onDeletePasskey={handleDeletePasskey}
            onEditCancel={() => setEditingPasskeyId(null)}
            onEditStart={setEditingPasskeyId}
            onUpdatePasskey={handleUpdatePasskey}
            passkeys={passkeys}
          />
        ) : null}
      </CardContent>
    </Card>
  );
};
