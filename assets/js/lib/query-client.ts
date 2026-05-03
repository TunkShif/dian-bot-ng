import { MutationCache, QueryClient, type QueryKey } from "@tanstack/react-query";
import { toast } from "sonner";
import { client } from "@/client/client.gen";

declare module "@tanstack/react-query" {
  interface Register {
    mutationMeta: {
      skipToast?: boolean;
      invalidatesQuery?: QueryKey;
      successTitle?: string;
      successMessage?: string;
      errorTitle?: string;
      errorMessage?: string;
    };
  }
}

const mutationCache = new MutationCache({
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
    if (mutation.meta?.invalidatesQuery) {
      queryClient.invalidateQueries({
        queryKey: mutation.meta.invalidatesQuery,
      });
    }
  },
});

export const queryClient = new QueryClient({ mutationCache });

export const setupClient = () => {
  const csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content");
  if (!csrfToken) {
    return console.error("CSRF-Token not found in current document, this is unexpteced.");
  }
  client.setConfig({
    baseUrl: window.location.origin,
    headers: {
      "x-csrf-token": csrfToken,
    },
  });
};
