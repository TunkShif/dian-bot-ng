import ky, { type HTTPError, type KyInstance } from "ky"
import invariant from "tiny-invariant"

export type SignInParams = {
  qid: string
  password: string
  device: string | null
  location: string | null
}

type AuthResult = { type: "unauthorized" } | { type: "unknown_error" }
export type SignInResult = { type: "signin_success"; token: string } | AuthResult
export type SignOutResult = { type: "signout_success" } | AuthResult

export class AuthService {
  client: KyInstance

  constructor(baseUrl: string, options?: { headers: HeadersInit | undefined }) {
    const authUrl = `${baseUrl}/api/auth`
    this.client = ky.create({
      prefixUrl: authUrl,
      headers: options?.headers,
      credentials: undefined
    })
  }

  async signIn(params: SignInParams): Promise<SignInResult> {
    try {
      const response = await this.client.post("login", { json: params })
      const authorization = response.headers.get("Authorization")
      invariant(authorization, "Authorization header cannot be null.")
      const token = authorization.substring("Bearer ".length)
      return { type: "signin_success", token }
    } catch (error) {
      const { response } = error as HTTPError
      return {
        type: response.status === 401 ? "unauthorized" : "unknown_error"
      }
    }
  }

  async signOut(): Promise<SignOutResult> {
    try {
      await this.client.delete("logout")
      return { type: "signout_success" }
    } catch (error) {
      const { response } = error as HTTPError
      return {
        type: response.status === 401 ? "unauthorized" : "unknown_error"
      }
    }
  }
}
