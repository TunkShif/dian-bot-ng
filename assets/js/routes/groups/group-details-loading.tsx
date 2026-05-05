import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";

export const GroupDetailsLoading = () => (
  <Card className="min-w-0">
    <CardHeader>
      <Skeleton className="size-10 rounded-full" />
      <Skeleton className="h-5 w-40" />
      <Skeleton className="h-4 w-56" />
    </CardHeader>
    <CardContent className="space-y-4">
      <Skeleton className="h-28 w-full" />
      <Skeleton className="h-64 w-full" />
    </CardContent>
  </Card>
);
