import { GameControllerIcon, SlidersHorizontalIcon, SparkleIcon, TrophyIcon } from "@phosphor-icons/react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { listGroupsQueryKey, showGroupQueryKey, updateGroupMutation } from "@/client/@tanstack/react-query.gen";
import { Switch } from "@/components/ui/switch";
import { cn } from "@/lib/utils";
import type { GroupDetail as GroupDetailType } from "@/routes/groups/types";

type GroupSettingsSectionProps = {
  group: GroupDetailType;
};

type FeatureKey = "steam_status_enabled" | "steam_achievements_enabled" | "daily_steam_summary_enabled";

const FEATURES = [
  {
    key: "steam_status_enabled",
    icon: GameControllerIcon,
    labelKey: "app.groups.settings.features.steamStatus.label",
    descriptionKey: "app.groups.settings.features.steamStatus.description",
  },
  {
    key: "steam_achievements_enabled",
    icon: TrophyIcon,
    labelKey: "app.groups.settings.features.achievements.label",
    descriptionKey: "app.groups.settings.features.achievements.description",
  },
  {
    key: "daily_steam_summary_enabled",
    icon: SparkleIcon,
    labelKey: "app.groups.settings.features.dailySummary.label",
    descriptionKey: "app.groups.settings.features.dailySummary.description",
  },
] as const;

export const GroupSettingsSection = ({ group }: GroupSettingsSectionProps) => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const { mutate, isPending } = useMutation({
    ...updateGroupMutation(),
    meta: {
      successMessage: t("app.groups.settings.update.successMessage"),
      errorMessage: t("app.groups.settings.update.errorMessage"),
    },
  });

  const invalidateGroupQueries = () => {
    void queryClient.invalidateQueries({ queryKey: listGroupsQueryKey() });
    void queryClient.invalidateQueries({
      queryKey: showGroupQueryKey({ path: { id: group.group_id.toString() } }),
    });
  };

  const handleFlagChange = (flag: "enabled" | FeatureKey, value: boolean) => {
    mutate(
      {
        path: { id: group.group_id.toString() },
        body: { [flag]: value },
      },
      { onSuccess: invalidateGroupQueries },
    );
  };

  // Track whether any feature has ever been enabled during this session
  // so the post-enable hint doesn't reappear once dismissed.
  const [hasEverEnabledFeature] = useState(
    () => group.steam_status_enabled || group.steam_achievements_enabled || group.daily_steam_summary_enabled,
  );

  const anyFeatureOn =
    group.steam_status_enabled || group.steam_achievements_enabled || group.daily_steam_summary_enabled;

  const showHint = group.enabled && !anyFeatureOn && !hasEverEnabledFeature;

  return (
    <section className="rounded-xl border border-border/70 bg-muted/30 p-4">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="space-y-1">
          <div className="flex items-center gap-2 text-sm font-medium text-foreground">
            <SlidersHorizontalIcon className="size-4 text-muted-foreground" />
            {t("app.groups.settings.title")}
          </div>
          <p className="max-w-md text-sm text-muted-foreground">
            {group.is_admin ? t("app.groups.settings.description") : t("app.groups.settings.adminOnlyDescription")}
          </p>
        </div>
        <label
          className="flex shrink-0 items-center justify-between gap-3 rounded-full border border-border/70 bg-background px-3 py-2 text-sm font-medium shadow-sm shadow-foreground/3"
          htmlFor="group-enabled-switch"
        >
          <span>{group.enabled ? t("app.groups.status.enabled") : t("app.groups.status.disabled")}</span>
          <Switch
            id="group-enabled-switch"
            checked={group.enabled}
            disabled={!group.is_admin || isPending}
            onCheckedChange={(checked) => handleFlagChange("enabled", checked === true)}
            aria-label={t("app.groups.settings.enabledLabel")}
          />
        </label>
      </div>

      <div
        data-state={group.enabled ? "open" : "closed"}
        className={cn(
          "grid transition-all duration-200 ease-out",
          group.enabled ? "grid-rows-[1fr] opacity-100" : "grid-rows-[0fr] opacity-0",
        )}
      >
        <div className="overflow-hidden">
          <div className="mt-4 rounded-lg border border-border/70 bg-background/60 p-2">
            {showHint ? (
              <div className="px-2 py-3 text-sm text-muted-foreground">
                {t("app.groups.settings.features.enabledHint")}
              </div>
            ) : null}
            <ul className="divide-y divide-border/50">
              {FEATURES.map((feature) => {
                const Icon = feature.icon;
                return (
                  <li key={feature.key} className="flex items-center justify-between gap-3 px-2 py-3">
                    <div className="flex min-w-0 items-start gap-3">
                      <Icon className="mt-0.5 size-5 shrink-0 text-muted-foreground" />
                      <div className="min-w-0 space-y-0.5">
                        <div className="text-sm font-medium text-foreground">{t(feature.labelKey)}</div>
                        <div className="text-xs text-muted-foreground">{t(feature.descriptionKey)}</div>
                      </div>
                    </div>
                    <Switch
                      size="sm"
                      checked={group[feature.key]}
                      disabled={!group.is_admin || isPending}
                      onCheckedChange={(checked) => handleFlagChange(feature.key, checked === true)}
                      aria-label={t(feature.labelKey)}
                    />
                  </li>
                );
              })}
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
};
