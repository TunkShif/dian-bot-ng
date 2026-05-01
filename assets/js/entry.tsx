import { NuqsAdapter } from "nuqs/adapters/react-router/v6";
import * as React from "react";
import * as ReactDOM from "react-dom/client";
import { HelmetProvider } from "react-helmet-async";
import { RouterProvider } from "react-router-dom";
import { TooltipProvider } from "@/components/ui/tooltip";
import { router } from "@/router";

const App = () => {
  return (
    <HelmetProvider>
      <NuqsAdapter>
        <TooltipProvider>
          <RouterProvider router={router} />
        </TooltipProvider>
      </NuqsAdapter>
    </HelmetProvider>
  );
};

export const renderApp = () => {
  const root = document.getElementById("root");
  if (!root) {
    return console.error("Root element not found");
  }
  ReactDOM.createRoot(root).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>,
  );
};
