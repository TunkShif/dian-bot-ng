import ky, { type KyInstance } from "ky"
import { z } from "zod"

export const signInFormSchema = z.object({
  qid: z.string(),
  password: z.string()
})

export type SignInFormSchema = z.infer<typeof signInFormSchema>

type AuthResponse = {
  success: boolean
}

// TODO: error handling

export class AuthService {
  client: KyInstance

  constructor(baseURL: string, options: { headers: HeadersInit | undefined }) {
    this.client = ky.create({ prefixUrl: baseURL, headers: options?.headers })
  }

  signIn(params: SignInFormSchema) {
    return this.client.post("/api/auth/login", { json: params })
  }

  signOut() {
    return this.client.delete("/api/auth/logout")
  }
}
