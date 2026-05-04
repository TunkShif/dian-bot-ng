import { createBrowserRouter } from "react-router-dom";
import { Component, loader as rootLoader } from "@/routes/root";

// TODO: error boundary

export const router = createBrowserRouter(
  [
    {
      loader: rootLoader,
      Component,
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
