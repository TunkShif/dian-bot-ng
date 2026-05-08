import { QueryClientProvider } from "@tanstack/react-query";
import { ThemeProvider } from "next-themes";
import { NuqsAdapter } from "nuqs/adapters/react-router/v6";
import * as React from "react";
import * as ReactDOM from "react-dom/client";
import { HelmetProvider } from "react-helmet-async";
import { RouterProvider } from "react-router-dom";
import { Toaster } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { queryClient } from "@/lib/query-client";
import { router } from "@/router";

const App = () => {
  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem disableTransitionOnChange>
      <HelmetProvider>
        <NuqsAdapter>
          <QueryClientProvider client={queryClient}>
            <TooltipProvider>
              <RouterProvider router={router} />
              <Toaster position="top-center" />
            </TooltipProvider>
          </QueryClientProvider>
        </NuqsAdapter>
      </HelmetProvider>
    </ThemeProvider>
  );
};

export const renderApp = () => {
  const root = document.getElementById("root");
  if (!root) {
    return console.error("Root element not found in current document, this is unexpected.");
  }
  ReactDOM.createRoot(root).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>,
  );
};
