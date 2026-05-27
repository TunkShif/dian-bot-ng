import {
  BrainIcon,
  ChatCircleTextIcon,
  ClockCounterClockwiseIcon,
  DownloadSimpleIcon,
  GameControllerIcon,
  GearSixIcon,
  HouseIcon,
  MegaphoneIcon,
  MonitorPlayIcon,
  RankingIcon,
  ShieldCheckIcon,
  SlidersHorizontalIcon,
  SparkleIcon,
  UsersThreeIcon,
} from "@phosphor-icons/react";
import type * as React from "react";
import type Resources from "@/types/i18n/resources";

type NavTranslationKey = `app.nav.${Extract<keyof Resources["translation"]["app"]["nav"], string>}`;

export type NavigationItem = {
  titleKey: NavTranslationKey;
  url: string;
  icon?: React.ReactNode;
  items?: {
    titleKey: NavTranslationKey;
    url: string;
    icon?: React.ReactNode;
  }[];
};

export const navigationMenu: NavigationItem[] = [
  {
    titleKey: "app.nav.dashboard",
    url: "/dashboard",
    icon: <HouseIcon />,
  },
  {
    titleKey: "app.nav.featuredMessages",
    url: "/messages",
    icon: <ChatCircleTextIcon />,
  },
  {
    titleKey: "app.nav.gameCenter",
    url: "/games",
    icon: <GameControllerIcon />,
    items: [
      {
        titleKey: "app.nav.liveMonitor",
        url: "/games/monitor",
        icon: <MonitorPlayIcon />,
      },
      {
        titleKey: "app.nav.gameHistory",
        url: "/games/history",
        icon: <ClockCounterClockwiseIcon />,
      },
    ],
  },
  {
    titleKey: "app.nav.groups",
    url: "/groups",
    icon: <UsersThreeIcon />,
  },
  {
    titleKey: "app.nav.aiAssistant",
    url: "/ai/",
    icon: <BrainIcon />,
    items: [
      {
        titleKey: "app.nav.autoAnalysis",
        url: "/ai/foo",
        icon: <SparkleIcon />,
      },
      {
        titleKey: "app.nav.aiRankings",
        url: "/ai/bar",
        icon: <RankingIcon />,
      },
      {
        titleKey: "app.nav.roastAlerts",
        url: "/ai/baz",
        icon: <MegaphoneIcon />,
      },
    ],
  },
  {
    titleKey: "app.nav.systemSettings",
    url: "/settings",
    icon: <GearSixIcon />,
    items: [
      {
        titleKey: "app.nav.globalConfig",
        url: "/settings/system",
        icon: <SlidersHorizontalIcon />,
      },
      {
        titleKey: "app.nav.permissionManagement",
        url: "/settings/permissions",
        icon: <ShieldCheckIcon />,
      },
      {
        titleKey: "app.nav.dataExport",
        url: "/settings/export",
        icon: <DownloadSimpleIcon />,
      },
    ],
  },
];
