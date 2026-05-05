import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";

type MemberPaginationProps = {
  page: number;
  totalPages: number;
  totalItems: number;
  onPageChange: (page: number) => void;
};

export const MemberPagination = ({ page, totalPages, totalItems, onPageChange }: MemberPaginationProps) => {
  const { t } = useTranslation();

  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
      <p className="text-sm text-muted-foreground">
        {t("app.groups.members.pagination.page")} {page} {t("app.groups.members.pagination.of")} {totalPages} ·{" "}
        {t("app.groups.members.pagination.total", { count: totalItems })}
      </p>
      <div className="flex items-center gap-2">
        <Button type="button" variant="outline" size="sm" disabled={page <= 1} onClick={() => onPageChange(page - 1)}>
          {t("app.groups.members.pagination.previous")}
        </Button>
        <Button
          type="button"
          variant="outline"
          size="sm"
          disabled={page >= totalPages}
          onClick={() => onPageChange(page + 1)}
        >
          {t("app.groups.members.pagination.next")}
        </Button>
      </div>
    </div>
  );
};
