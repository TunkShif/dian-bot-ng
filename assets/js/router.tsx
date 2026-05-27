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
              path: "/groups",
              lazy: () => import("@/routes/groups"),
            },
            {
              path: "/settings/user",
              lazy: () => import("@/routes/settings.user"),
            },
            {
              path: "/settings/system",
              lazy: () => import("@/routes/settings.system"),
            },
            {
              path: "/settings/permissions",
              lazy: () => import("@/routes/settings.permissions"),
            },
            {
              path: "/settings/export",
              lazy: () => import("@/routes/settings.export"),
            },
            {
              path: "/games/monitor",
              lazy: () => import("@/routes/games.monitor"),
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
