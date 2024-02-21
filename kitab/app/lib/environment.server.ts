import { z } from "zod"

export const environmentSchema = z.object({
  HAFIZ_API_URL: z.string()
})

export type EnvironmentSchema = z.infer<typeof environmentSchema>
