import { getCurrentUserOptions } from "@/client/@tanstack/react-query.gen";
import { queryClient } from "@/lib/query-client";

export type User = NonNullable<Awaited<ReturnType<typeof getCurrentUser>>>;

export const getCurrentUser = async () => {
  const response = await queryClient.fetchQuery(getCurrentUserOptions());
  return response.data.user;
};
