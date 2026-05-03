import { createBrowserRouter } from "react-router-dom";

// TODO: error boundary
// TODO: add server flash data toast

export const router = createBrowserRouter(
  [
    {
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
