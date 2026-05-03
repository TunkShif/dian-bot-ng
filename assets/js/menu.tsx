import {
  AddressBookTabsIcon,
  BrainIcon,
  ChatCircleTextIcon,
  ClockCounterClockwiseIcon,
  GameControllerIcon,
  GearSixIcon,
  HouseIcon,
  MegaphoneIcon,
  MonitorPlayIcon,
  RankingIcon,
  ShieldCheckIcon,
  SlidersHorizontalIcon,
  SparkleIcon,
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
    icon: <ChatCircleTextIcon />,
  },
  {
    titleKey: "app.nav.gameCenter",
    url: "#",
    icon: <GameControllerIcon />,
    items: [
      {
        titleKey: "app.nav.liveMonitor",
        url: "#",
        icon: <MonitorPlayIcon />,
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
        icon: <AddressBookTabsIcon />,
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
    icon: <BrainIcon />,
    items: [
      {
        titleKey: "app.nav.autoAnalysis",
        url: "#",
        icon: <SparkleIcon />,
      },
      {
        titleKey: "app.nav.aiRankings",
        url: "#",
        icon: <RankingIcon />,
      },
      {
        titleKey: "app.nav.roastAlerts",
        url: "#",
        icon: <MegaphoneIcon />,
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
        icon: <SlidersHorizontalIcon />,
      },
      {
        titleKey: "app.nav.permissionManagement",
        url: "#",
        icon: <ShieldCheckIcon />,
      },
    ],
  },
];
