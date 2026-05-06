import { Skeleton } from "@/components/ui/skeleton";

export const SteamLoadingState = () => (
  <div className="flex items-start gap-4 rounded-lg border p-4">
    <Skeleton className="size-14 shrink-0 rounded-full" />
    <div className="flex min-w-0 flex-1 flex-col gap-2">
      <Skeleton className="h-5 w-40" />
      <Skeleton className="h-4 w-52" />
      <Skeleton className="h-4 w-32" />
    </div>
  </div>
);
