import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";

type GroupPaginationProps = {
  page: number;
  totalPages: number;
  totalItems: number;
  onPageChange: (page: number) => void;
};

export const GroupPagination = ({ page, totalPages, totalItems, onPageChange }: GroupPaginationProps) => {
  const { t } = useTranslation();

  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
      <p className="text-sm text-muted-foreground">
        {t("app.groups.pagination.page")} {page} {t("app.groups.pagination.of")} {totalPages} ·{" "}
        {t("app.groups.pagination.total", { count: totalItems })}
      </p>
      <div className="flex items-center gap-2">
        <Button type="button" variant="outline" size="sm" disabled={page <= 1} onClick={() => onPageChange(page - 1)}>
          {t("app.groups.pagination.previous")}
        </Button>
        <Button
          type="button"
          variant="outline"
          size="sm"
          disabled={page >= totalPages}
          onClick={() => onPageChange(page + 1)}
        >
          {t("app.groups.pagination.next")}
        </Button>
      </div>
    </div>
  );
};
