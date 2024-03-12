import { z } from "zod"

export const createPaginationSchema = (pageSize: number) =>
  z.union([
    z
      .object({
        before: z.string()
      })
      .transform((val) => ({ last: pageSize, before: val.before })),
    z
      .object({
        after: z.string()
      })
      .transform((val) => ({ first: pageSize, after: val.after })),
    z
      .object({})
      .strict()
      .transform(() => ({ first: pageSize }))
  ])
