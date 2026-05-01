import * as React from "react";
import * as ReactDOM from "react-dom/client";
import { RouterProvider } from "react-router-dom";
import { router } from "@/router";

export const renderApp = () => {
  const root = document.getElementById("root");
  if (!root) {
    return console.error("Root element not found");
  }
  ReactDOM.createRoot(root).render(
    <React.StrictMode>
      <RouterProvider router={router} />
    </React.StrictMode>,
  );
};
