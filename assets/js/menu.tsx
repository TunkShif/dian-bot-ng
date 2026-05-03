import {
  BellRingingIcon,
  ChartBarIcon,
  ChartLineUpIcon,
  ClockCounterClockwiseIcon,
  FloppyDiskBackIcon,
  GearSixIcon,
  HouseIcon,
  ListBulletsIcon,
  MedalIcon,
  NoteIcon,
  RobotIcon,
  ShieldCheckIcon,
  SlidersHorizontalIcon,
  SparkleIcon,
  TrophyIcon,
  UserCircleIcon,
  UserListIcon,
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
    url: "#",
    icon: <ClockCounterClockwiseIcon />,
    items: [
      {
        titleKey: "app.nav.favoriteThreads",
        url: "#",
        icon: <FloppyDiskBackIcon />,
      },
      {
        titleKey: "app.nav.hotRankings",
        url: "#",
        icon: <MedalIcon />,
      },
    ],
  },
  {
    titleKey: "app.nav.gameCenter",
    url: "#",
    icon: <TrophyIcon />,
    items: [
      {
        titleKey: "app.nav.liveMonitor",
        url: "#",
        icon: <ChartLineUpIcon />,
      },
      {
        titleKey: "app.nav.gameHistory",
        url: "#",
        icon: <ClockCounterClockwiseIcon />,
      },
    ],
  },
  {
    titleKey: "app.nav.groupManagement",
    url: "#",
    icon: <UsersThreeIcon />,
    items: [
      {
        titleKey: "app.nav.groupList",
        url: "#",
        icon: <ListBulletsIcon />,
      },
      {
        titleKey: "app.nav.groupUsers",
        url: "#",
        icon: <UserListIcon />,
      },
    ],
  },
  {
    titleKey: "app.nav.aiAssistant",
    url: "#",
    icon: <RobotIcon />,
    items: [
      {
        titleKey: "app.nav.autoAnalysis",
        url: "#",
        icon: <SparkleIcon />,
      },
      {
        titleKey: "app.nav.aiRankings",
        url: "#",
        icon: <ChartBarIcon />,
      },
      {
        titleKey: "app.nav.roastAlerts",
        url: "#",
        icon: <BellRingingIcon />,
      },
    ],
  },
  {
    titleKey: "app.nav.profile",
    url: "#",
    icon: <UserCircleIcon />,
    items: [
      {
        titleKey: "app.nav.myInfo",
        url: "#",
        icon: <NoteIcon />,
      },
      {
        titleKey: "app.nav.accountSettings",
        url: "#",
        icon: <SlidersHorizontalIcon />,
      },
    ],
  },
  {
    titleKey: "app.nav.systemSettings",
    url: "#",
    icon: <GearSixIcon />,
    items: [
      {
        titleKey: "app.nav.globalConfig",
        url: "#",
        icon: <GearSixIcon />,
      },
      {
        titleKey: "app.nav.permissionManagement",
        url: "#",
        icon: <ShieldCheckIcon />,
      },
    ],
  },
];
