import { MutationCache, QueryClient, type QueryKey } from "@tanstack/react-query";
import { toast } from "sonner";
import topbar from "topbar";
import { client } from "@/client/client.gen";
import { getCsrfToken } from "@/lib/utils";

declare module "@tanstack/react-query" {
  interface Register {
    mutationMeta: {
      skipToast?: boolean;
      invalidatesQueries?: QueryKey[];
      successTitle?: string;
      successMessage?: string;
      errorTitle?: string;
      errorMessage?: string;
    };
  }
}

const mutationCache = new MutationCache({
  onMutate: (_variables, _mutation, _context) => {
    topbar.show(300);
  },
  onSuccess: (_data, _variables, _context, mutation) => {
    if (mutation.meta?.successMessage && !mutation.meta?.skipToast) {
      mutation.meta.successTitle
        ? toast.success(mutation.meta.successTitle, { description: mutation.meta.successMessage })
        : toast.success(mutation.meta.successMessage);
    }
  },
  onError: (error, _variables, _context, mutation) => {
    console.error("Mutarion error", error);
    if (mutation.meta?.errorMessage && !mutation.meta?.skipToast) {
      mutation.meta.errorTitle
        ? toast.error(mutation.meta.errorTitle, { description: mutation.meta.errorMessage })
        : toast.error(mutation.meta.errorMessage);
    }
  },
  onSettled: (_data, _error, _variables, _context, mutation) => {
    topbar.hide();
    if (mutation.meta?.invalidatesQueries) {
      mutation.meta.invalidatesQueries.forEach((queryKey) => {
        queryClient.invalidateQueries({ queryKey });
      });
    }
  },
});

export const queryClient = new QueryClient({ mutationCache });

export const setupClient = () => {
  const csrfToken = getCsrfToken();
  client.setConfig({
    baseUrl: window.location.origin,
    headers: {
      "x-csrf-token": csrfToken,
    },
  });
};
