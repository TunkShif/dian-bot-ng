import { z } from "zod"

export const environmentSchema = z.object({
  HAFIZ_API_URL: z.string(),
  HAFIZ_SOCKET_URL: z.string(),
  SESSION_SECRET: z.string()
})

export type EnvironmentSchema = z.infer<typeof environmentSchema>
