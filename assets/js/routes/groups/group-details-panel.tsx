import { useQuery } from "@tanstack/react-query";
import { useTranslation } from "react-i18next";
import { showGroupOptions } from "@/client/@tanstack/react-query.gen";
import { Card, CardContent } from "@/components/ui/card";
import { GroupDetails } from "@/routes/groups/group-details";
import { GroupDetailsError } from "@/routes/groups/group-details-error";
import { GroupDetailsLoading } from "@/routes/groups/group-details-loading";
import type { GroupListItem } from "@/routes/groups/types";

type GroupDetailsPanelProps = {
  group: GroupListItem | undefined;
};

export const GroupDetailsPanel = ({ group }: GroupDetailsPanelProps) => {
  const { t } = useTranslation();
  const groupId = group?.group_id;
  const detailQuery = useQuery({
    ...showGroupOptions({ path: { id: (groupId ?? 0).toString() } }),
    enabled: typeof groupId === "number",
  });

  if (!group) {
    return (
      <Card className="min-w-0">
        <CardContent className="flex min-h-80 items-center justify-center py-12 text-sm text-muted-foreground">
          {t("app.groups.details.noSelection")}
        </CardContent>
      </Card>
    );
  }

  if (detailQuery.isLoading) {
    return <GroupDetailsLoading />;
  }

  if (detailQuery.isError) {
    return <GroupDetailsError onRetry={() => void detailQuery.refetch()} />;
  }

  const detail = detailQuery.data?.data.group;

  return detail ? <GroupDetails group={detail} /> : null;
};
