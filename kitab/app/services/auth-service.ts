import { graphql } from "gql"
import type { HTTPError, KyInstance } from "ky"
import invariant from "tiny-invariant"

type SignInParams = {
  qid: string
  password: string
  device: string | null
  location: string | null
}

type ConfirmRegistraionParams = {
  password: string
  password_confirmation: string
}

type RegistrationResponse =
  | { success: true }
  | { success: false; reason: "invalid_email" }
  | { success: false; reason: "invalid_account" }
  | { success: false; reason: "already_requested" }
  | { success: false; reason: "already_registered" }
  | { success: false; reason: "invalid_token" }
  | { success: false; reason: "invalid_params"; errors: Record<string, string[]> }

type AuthResult = { type: "unauthorized" } | { type: "unknown_error" }
type SignInResult = { type: "signin_success"; token: string } | AuthResult
type SignOutResult = { type: "signout_success" } | AuthResult
type RequestRegistrationResult =
  | { type: "request_success" }
  | { type: "already_requested" }
  | { type: "already_registered" }
  | AuthResult

export class AuthService {
  client: KyInstance

  constructor(client: KyInstance) {
    this.client = client
  }

  async requestRegistration(email: string): Promise<RequestRegistrationResult> {
    try {
      await this.client.post("user/create", { json: { email } })
      return { type: "request_success" }
    } catch (error) {
      const { response } = error as HTTPError
      const result = await response.json<RegistrationResponse>()
      invariant(!result.success)
      switch (result.reason) {
        case "invalid_email":
        case "invalid_account":
          return { type: "unauthorized" }
        case "already_requested":
          return { type: "already_requested" }
        case "already_registered":
          return { type: "already_registered" }
        default:
          return { type: "unknown_error" }
      }
    }
  }

  async verifyRegistration(token: string) {
    try {
      await this.client.post(`user/verify/${encodeURIComponent(token)}`)
      return true
    } catch (error) {
      return false
    }
  }

  async confirmRegistration(token: string, params: ConfirmRegistraionParams) {
    try {
      await this.client.post(`user/confirm/${encodeURIComponent(token)}`, { json: params })
      return true
    } catch (error) {
      return false
    }
  }

  async signIn(params: SignInParams): Promise<SignInResult> {
    try {
      const response = await this.client.post("auth/login", { json: params })
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
      await this.client.delete("auth/logout")
      return { type: "signout_success" }
    } catch (error) {
      const { response } = error as HTTPError
      return {
        type: response.status === 401 ? "unauthorized" : "unknown_error"
      }
    }
  }
}

export const CurrentUserQuery = graphql(`
  query CurrentUser {
    me {
      id
      qid
      role
      name
    }
  }
`)
