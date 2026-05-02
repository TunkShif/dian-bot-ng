import { createBrowserRouter } from "react-router-dom";
import { DashboardPage } from "@/routes/dashboard";
import { AppShell } from "@/routes/layout";
import { LoginPage } from "@/routes/login";

export const router = createBrowserRouter(
  [
    {
      path: "/login",
      element: <LoginPage />,
    },
    {
      element: <AppShell />,
      children: [
        {
          path: "/dashboard",
          element: <DashboardPage />,
        },
      ],
    },
  ],
  {
    basename: "/app",
  },
);
