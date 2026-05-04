import type {
  GroupAccessFilter,
  GroupListItem,
  GroupMember,
  GroupStatusFilter,
  MemberRoleFilter,
} from "@/routes/groups/types";

export const GROUPS_PAGE_SIZE = 8;
export const MEMBERS_PAGE_SIZE = 8;

type GroupFilters = {
  query: string;
  status: GroupStatusFilter;
  access: GroupAccessFilter;
};

type MemberFilters = {
  query: string;
  role: MemberRoleFilter;
};

export const filterGroups = (groups: GroupListItem[], filters: GroupFilters) => {
  const normalizedQuery = filters.query.trim().toLowerCase();

  return groups.filter((group) => {
    const matchesQuery =
      normalizedQuery.length === 0 ||
      group.group_name.toLowerCase().includes(normalizedQuery) ||
      group.group_id.toString().includes(normalizedQuery);

    const matchesStatus =
      filters.status === "all" ||
      (filters.status === "enabled" && group.enabled) ||
      (filters.status === "disabled" && !group.enabled);

    const matchesAccess =
      filters.access === "all" ||
      (filters.access === "admin" && group.is_admin) ||
      (filters.access === "member" && !group.is_admin);

    return matchesQuery && matchesStatus && matchesAccess;
  });
};

export const paginateGroups = (groups: GroupListItem[], page: number, pageSize = GROUPS_PAGE_SIZE) => {
  const totalPages = Math.max(1, Math.ceil(groups.length / pageSize));
  const safePage = Math.min(Math.max(page, 1), totalPages);
  const start = (safePage - 1) * pageSize;

  return {
    page: safePage,
    totalPages,
    groups: groups.slice(start, start + pageSize),
  };
};

export const filterMembers = (members: GroupMember[], filters: MemberFilters) => {
  const normalizedQuery = filters.query.trim().toLowerCase();

  return members.filter((member) => {
    const displayName = member.display_name ?? "";
    const title = member.title ?? "";
    const matchesQuery =
      normalizedQuery.length === 0 ||
      member.nickname.toLowerCase().includes(normalizedQuery) ||
      displayName.toLowerCase().includes(normalizedQuery) ||
      title.toLowerCase().includes(normalizedQuery) ||
      member.user_id.toString().includes(normalizedQuery);

    const matchesRole =
      filters.role === "all" ||
      (filters.role === "robot" && member.is_robot) ||
      (filters.role !== "robot" && member.role === filters.role);

    return matchesQuery && matchesRole;
  });
};

export const paginateMembers = (members: GroupMember[], page: number, pageSize = MEMBERS_PAGE_SIZE) => {
  const totalPages = Math.max(1, Math.ceil(members.length / pageSize));
  const safePage = Math.min(Math.max(page, 1), totalPages);
  const start = (safePage - 1) * pageSize;

  return {
    page: safePage,
    totalPages,
    members: members.slice(start, start + pageSize),
  };
};
