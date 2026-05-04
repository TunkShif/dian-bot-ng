import type { GroupListResponse, GroupResponse } from "@/client";

export type GroupListItem = GroupListResponse["data"]["groups"][number];
export type GroupDetail = GroupResponse["data"]["group"];
export type GroupMember = GroupDetail["members"][number];

export type GroupStatusFilter = "all" | "enabled" | "disabled";
export type GroupAccessFilter = "all" | "admin" | "member";
export type MemberRoleFilter = "all" | "owner" | "admin" | "member" | "robot";
