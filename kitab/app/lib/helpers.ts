import { addHours, format, parseISO } from "date-fns"

/**
 * Combine multiple header objects into one (uses append so headers are not overridden)
 */
export function combineHeaders(...headers: Array<ResponseInit["headers"] | null | undefined>) {
  const combined = new Headers()
  for (const header of headers) {
    if (!header) continue
    for (const [key, value] of new Headers(header).entries()) {
      combined.append(key, value)
    }
  }
  return combined
}

export const formatDateTime = (datetime: string) =>
  format(addHours(parseISO(datetime), 8), "yyyy-MM-dd HH:mm")
