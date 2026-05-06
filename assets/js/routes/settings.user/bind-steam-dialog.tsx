import { CheckIcon, MagnifyingGlassIcon, SpinnerGapIcon } from "@phosphor-icons/react";
import { useForm } from "@tanstack/react-form";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import * as z from "zod";
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
  DialogTrigger,
} from "@/components/ui/dialog";
import { Field, FieldDescription, FieldError, FieldGroup, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { useCurrentUser } from "@/hooks/use-current-user";
import { hasHttpStatus, STEAM_ID_REGEX, useBindSelfSteamMutation, useSteamPlayerLookup } from "@/lib/steam";

const steamIdSchema = z.object({
  steam_id: z
    .string()
    .min(17, "Steam ID must be 17 characters")
    .max(17, "Steam ID must be 17 characters")
    .regex(STEAM_ID_REGEX, "Must be a valid Steam ID starting with 7656"),
});

export const BindSteamDialog = () => {
  const { t } = useTranslation();
  const user = useCurrentUser();
  const [open, setOpen] = useState(false);
  const [lookupId, setLookupId] = useState<string | null>(null);

  const lookupQuery = useSteamPlayerLookup(lookupId);
  const bindMutation = useBindSelfSteamMutation(user?.qq_id ?? null);

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
      { body: { steam_id: lookupId } },
      {
        onSuccess: () => {
          form.reset();
          setLookupId(null);
          setOpen(false);
        },
      },
    );
  };

  const handleOpenChange = (value: boolean) => {
    setOpen(value);
    if (!value) {
      setLookupId(null);
      form.reset();
    }
  };

  const handleBack = () => {
    setLookupId(null);
  };

  const isPending = bindMutation.isPending;

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogTrigger render={<Button type="button" />}>
        <MagnifyingGlassIcon data-icon="inline-start" />
        {t("app.settings.steam.bind.trigger")}
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{t("app.settings.steam.bind.title")}</DialogTitle>
          <DialogDescription>{t("app.settings.steam.bind.description")}</DialogDescription>
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
                        disabled={isPending}
                      />
                      {isInvalid && <FieldError errors={field.state.meta.errors} />}
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
            {lookupQuery.isLoading ? (
              <div className="flex items-center justify-center py-8">
                <SpinnerGapIcon className="size-6 animate-spin text-muted-foreground" />
              </div>
            ) : lookupQuery.isError ? (
              <div className="rounded-lg border border-destructive/50 bg-destructive/5 p-4 text-sm text-destructive">
                {hasHttpStatus(lookupQuery.error, 404)
                  ? t("app.settings.steam.bind.lookupError")
                  : t("app.settings.steam.bind.lookupServiceError")}
              </div>
            ) : lookupQuery.data ? (
              <SteamPlayerSummaryCard player={lookupQuery.data} />
            ) : null}

            <DialogFooter>
              <Button type="button" variant="outline" onClick={handleBack} disabled={isPending}>
                {t("app.settings.steam.bind.back")}
              </Button>
              {lookupQuery.data && (
                <Button type="button" onClick={handleConfirm} disabled={isPending}>
                  {isPending ? (
                    <SpinnerGapIcon data-icon="inline-start" className="animate-spin" />
                  ) : (
                    <CheckIcon data-icon="inline-start" />
                  )}
                  {t("app.settings.steam.bind.confirm")}
                </Button>
              )}
            </DialogFooter>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
};
