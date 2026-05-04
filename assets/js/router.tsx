import { createBrowserRouter } from "react-router-dom";
import { Component, ErrorBoundary, loader as rootLoader } from "@/routes/root";

export const router = createBrowserRouter(
  [
    {
      loader: rootLoader,
      Component,
      ErrorBoundary,
      children: [
        {
          path: "/login",
          lazy: () => import("@/routes/login"),
        },
        {
          lazy: () => import("@/routes/layout"),
          children: [
            {
              path: "/dashboard",
              lazy: () => import("@/routes/dashboard"),
            },
            {
              path: "/settings/user",
              lazy: () => import("@/routes/settings.user"),
            },
          ],
        },
      ],
    },
  ],
  {
    basename: "/app",
  },
);
