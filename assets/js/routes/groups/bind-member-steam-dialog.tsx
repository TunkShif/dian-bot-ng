import { CheckIcon, MagnifyingGlassIcon, SpinnerGapIcon } from "@phosphor-icons/react";
import { useForm } from "@tanstack/react-form";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { SteamPlayerSummaryCard } from "@/components/steam-player-summary-card";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Field, FieldDescription, FieldError, FieldGroup, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { hasHttpStatus, steamIdSchema, useBindMemberSteamMutation, useSteamPlayerLookup } from "@/lib/steam";
import type { GroupMember } from "@/routes/groups/types";

type BindMemberSteamDialogProps = {
  groupId: string;
  member: GroupMember;
  open: boolean;
  onOpenChange: (open: boolean) => void;
};

export const BindMemberSteamDialog = ({ groupId, member, open, onOpenChange }: BindMemberSteamDialogProps) => {
  const { t } = useTranslation();
  const bindMutation = useBindMemberSteamMutation(groupId);
  const memberName = member.display_name || member.nickname;
  const [lookupId, setLookupId] = useState<string | null>(null);
  const lookupResult = useSteamPlayerLookup(lookupId);

  const form = useForm({
    defaultValues: { steam_id: "" },
    validators: { onSubmit: steamIdSchema },
    onSubmit: ({ value }) => {
      setLookupId(value.steam_id);
    },
  });

  const handleConfirm = () => {
    if (!lookupId) return;

    bindMutation.mutate(
      {
        path: { group_id: groupId, qq_id: member.user_id.toString() },
        body: {
          steam_id: lookupId,
          display_name: lookupResult.data?.name ?? null,
        },
      },
      {
        onSuccess: () => {
          form.reset();
          setLookupId(null);
          onOpenChange(false);
        },
      },
    );
  };

  const handleDialogChange = (nextOpen: boolean) => {
    onOpenChange(nextOpen);
    if (!nextOpen) {
      setLookupId(null);
      form.reset();
    }
  };

  const handleBack = () => {
    setLookupId(null);
  };

  return (
    <Dialog open={open} onOpenChange={handleDialogChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>
            {member.steam_player
              ? t("app.groups.members.steam.rebindDialog.title", { member: memberName })
              : t("app.groups.members.steam.bindDialog.title", { member: memberName })}
          </DialogTitle>
          <DialogDescription>
            {member.steam_player
              ? t("app.groups.members.steam.rebindDialog.description", { member: memberName })
              : t("app.groups.members.steam.bindDialog.description", { member: memberName })}
          </DialogDescription>
        </DialogHeader>

        {lookupId === null ? (
          <form
            onSubmit={(event) => {
              event.preventDefault();
              form.handleSubmit();
            }}
          >
            <FieldGroup>
              <form.Field name="steam_id">
                {(field) => {
                  const isInvalid = field.state.meta.isTouched && !field.state.meta.isValid;

                  return (
                    <Field data-invalid={isInvalid}>
                      <FieldLabel htmlFor={field.name}>{t("app.settings.steam.bind.steamId.label")}</FieldLabel>
                      <Input
                        id={field.name}
                        name={field.name}
                        value={field.state.value}
                        onBlur={field.handleBlur}
                        onChange={(event) => field.handleChange(event.target.value)}
                        placeholder={t("app.settings.steam.bind.steamId.placeholder")}
                        disabled={bindMutation.isPending}
                      />
                      {isInvalid ? <FieldError errors={field.state.meta.errors} /> : null}
                      <FieldDescription>{t("app.settings.steam.bind.steamId.helper")}</FieldDescription>
                    </Field>
                  );
                }}
              </form.Field>
              <DialogFooter>
                <DialogClose render={<Button type="button" variant="outline" />}>
                  {t("app.settings.actions.cancel")}
                </DialogClose>
                <form.Subscribe selector={(state) => [state.canSubmit, state.isSubmitting]}>
                  {([canSubmit, isSubmitting]) => (
                    <Button type="submit" disabled={!canSubmit || isSubmitting}>
                      <MagnifyingGlassIcon data-icon="inline-start" />
                      {t("app.settings.steam.bind.lookup")}
                    </Button>
                  )}
                </form.Subscribe>
              </DialogFooter>
            </FieldGroup>
          </form>
        ) : (
          <div className="flex flex-col gap-4">
            {lookupResult.isLoading ? (
              <div className="flex items-center justify-center py-8">
                <SpinnerGapIcon className="size-6 animate-spin text-muted-foreground" />
              </div>
            ) : lookupResult.isError ? (
              <div className="rounded-lg border border-destructive/50 bg-destructive/5 p-4 text-sm text-destructive">
                {hasHttpStatus(lookupResult.error, 404)
                  ? t("app.settings.steam.bind.lookupError")
                  : t("app.settings.steam.bind.lookupServiceError")}
              </div>
            ) : lookupResult.data ? (
              <SteamPlayerSummaryCard player={lookupResult.data} />
            ) : null}

            <DialogFooter>
              <Button type="button" variant="outline" onClick={handleBack} disabled={bindMutation.isPending}>
                {t("app.settings.steam.bind.back")}
              </Button>
              {lookupResult.data ? (
                <Button type="button" onClick={handleConfirm} disabled={bindMutation.isPending}>
                  {bindMutation.isPending ? (
                    <SpinnerGapIcon data-icon="inline-start" className="animate-spin" />
                  ) : (
                    <CheckIcon data-icon="inline-start" />
                  )}
                  {member.steam_player
                    ? t("app.groups.members.steam.rebindDialog.confirm")
                    : t("app.groups.members.steam.bindDialog.confirm")}
                </Button>
              ) : null}
            </DialogFooter>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
};
