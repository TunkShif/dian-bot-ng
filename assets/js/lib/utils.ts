import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const getCsrfToken = () => {
  const csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content");
  if (!csrfToken) {
    console.error("CSRF-Token not found in current document, this is unexpteced.");
  }
  return csrfToken ?? "";
};
