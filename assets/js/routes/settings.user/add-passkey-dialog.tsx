import { FingerprintIcon, PlusIcon, SpinnerGapIcon } from "@phosphor-icons/react";
import { useForm } from "@tanstack/react-form";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import * as z from "zod";
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
import { useRegisterPasskeyMutation } from "@/routes/settings.user/use-register-passkey-mutation";

const labelSchema = z.object({
  label: z.string().min(1),
});

export const AddPasskeyDialog = () => {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);

  const { mutate, isPending } = useRegisterPasskeyMutation();

  const form = useForm({
    defaultValues: { label: "" },
    validators: { onSubmit: labelSchema },
    onSubmit: ({ value }) => {
      mutate(value.label, {
        onSuccess: () => {
          form.reset();
          setOpen(false);
        },
      });
    },
  });

  return (
    <Dialog open={open} onOpenChange={(value) => setOpen(value)}>
      <DialogTrigger render={<Button type="button" />}>
        <PlusIcon data-icon="inline-start" />
        {t("app.settings.passkeys.add")}
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{t("app.settings.passkeys.addDialog.title")}</DialogTitle>
          <DialogDescription>{t("app.settings.passkeys.addDialog.description")}</DialogDescription>
        </DialogHeader>
        <form
          onSubmit={(event) => {
            event.preventDefault();
            form.handleSubmit();
          }}
        >
          <FieldGroup>
            <form.Field name="label">
              {(field) => {
                const isInvalid = field.state.meta.isTouched && !field.state.meta.isValid;

                return (
                  <Field data-invalid={isInvalid}>
                    <FieldLabel htmlFor={field.name}>{t("app.settings.passkeys.addDialog.label")}</FieldLabel>
                    <Input
                      id={field.name}
                      name={field.name}
                      value={field.state.value}
                      onBlur={field.handleBlur}
                      onChange={(event) => field.handleChange(event.target.value)}
                      placeholder={t("app.settings.passkeys.addDialog.placeholder")}
                      disabled={isPending}
                    />
                    {isInvalid && <FieldError errors={field.state.meta.errors} />}
                  </Field>
                );
              }}
            </form.Field>
            <FieldDescription>{t("app.settings.passkeys.addDialog.helper")}</FieldDescription>
            <DialogFooter>
              <DialogClose render={<Button type="button" variant="outline" />}>
                {t("app.settings.actions.cancel")}
              </DialogClose>
              <form.Subscribe selector={(state) => [state.canSubmit, state.isSubmitting]}>
                {([canSubmit, isSubmitting]) => (
                  <Button type="submit" disabled={!canSubmit || isSubmitting || isPending}>
                    {isPending ? (
                      <SpinnerGapIcon data-icon="inline-start" className="animate-spin" />
                    ) : (
                      <FingerprintIcon data-icon="inline-start" />
                    )}
                    {t("app.settings.passkeys.addDialog.submit")}
                  </Button>
                )}
              </form.Subscribe>
            </DialogFooter>
          </FieldGroup>
        </form>
      </DialogContent>
    </Dialog>
  );
};
