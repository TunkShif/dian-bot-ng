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

export const toBase64Url = (buffer: ArrayBuffer) =>
  btoa(String.fromCharCode(...new Uint8Array(buffer)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=/g, "");

export const fromBase64Url = (str: string) => {
  const b64 = str.replace(/-/g, "+").replace(/_/g, "/");
  return Uint8Array.from(atob(b64), (c) => c.charCodeAt(0)).buffer;
};
