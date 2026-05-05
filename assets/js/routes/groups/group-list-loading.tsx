import { Skeleton } from "@/components/ui/skeleton";

export const GroupListLoading = () => (
  <div className="space-y-3">
    {["one", "two", "three", "four", "five"].map((row) => (
      <Skeleton key={row} className="h-16 w-full" />
    ))}
  </div>
);
