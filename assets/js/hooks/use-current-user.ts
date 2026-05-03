import { useQuery } from "@tanstack/react-query";
import { getCurrentUserOptions } from "@/client/@tanstack/react-query.gen";

export const useCurrentUser = () => {
  const { data: response } = useQuery(getCurrentUserOptions());
  return response?.data.user ?? null;
};
