import { useTranslation } from "react-i18next";
import type { GroupListItem } from "@/routes/groups/types";

type GroupSummaryProps = {
  groups: GroupListItem[];
};

export const GroupSummary = ({ groups }: GroupSummaryProps) => {
  const { t } = useTranslation();
  const enabledCount = groups.filter((group) => group.enabled).length;
  const adminCount = groups.filter((group) => group.is_admin).length;

  return (
    <div className="grid grid-cols-3 gap-2 sm:min-w-80">
      <SummaryMetric label={t("app.groups.summary.total")} value={groups.length} />
      <SummaryMetric label={t("app.groups.summary.enabled")} value={enabledCount} />
      <SummaryMetric label={t("app.groups.summary.admin")} value={adminCount} />
    </div>
  );
};

type SummaryMetricProps = {
  label: string;
  value: number;
};

const SummaryMetric = ({ label, value }: SummaryMetricProps) => (
  <div className="rounded-xl border border-border/70 bg-card/80 px-3 py-2 shadow-sm shadow-foreground/3">
    <div className="text-lg font-semibold tabular-nums text-foreground">{value}</div>
    <div className="truncate text-xs text-muted-foreground">{label}</div>
  </div>
);
