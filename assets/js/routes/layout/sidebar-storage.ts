import type { NavigationItem } from "@/menu";

export const NAV_MENU_EXPANSION_STORAGE_KEY = "dian.navMenu.expanded";

export type NavMenuExpansionState = Partial<Record<NavigationItem["titleKey"], boolean>>;

export function getStoredNavMenuExpansionState(storage: Storage): NavMenuExpansionState {
  const value = safeGetItem(storage);
  if (!value) {
    return {};
  }

  try {
    const parsed = JSON.parse(value);
    if (!isRecord(parsed)) {
      return {};
    }

    return Object.fromEntries(
      Object.entries(parsed).filter((entry): entry is [NavigationItem["titleKey"], boolean] => {
        const [, itemOpen] = entry;
        return typeof itemOpen === "boolean";
      }),
    );
  } catch {
    return {};
  }
}

export function setStoredNavMenuExpansionState(storage: Storage, state: NavMenuExpansionState) {
  try {
    storage.setItem(NAV_MENU_EXPANSION_STORAGE_KEY, JSON.stringify(state));
  } catch {
    // Storage can be unavailable in some browser privacy modes.
  }
}

function safeGetItem(storage: Storage) {
  try {
    return storage.getItem(NAV_MENU_EXPANSION_STORAGE_KEY);
  } catch {
    return null;
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
