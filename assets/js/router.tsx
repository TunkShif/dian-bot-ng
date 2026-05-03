import { createBrowserRouter } from "react-router-dom";

export const router = createBrowserRouter(
  [
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
      ],
    },
  ],
  {
    basename: "/app",
  },
);
