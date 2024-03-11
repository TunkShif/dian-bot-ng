import { type LoaderFunctionArgs, json } from "@remix-run/cloudflare"
import { useLoaderData } from "@remix-run/react"
import invariant from "tiny-invariant"
import { UsersQuery } from "~/queries/users"

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const usersResult = await client.query(UsersQuery, { first: 20 }).toPromise()
  invariant(usersResult.data)

  return json({
    users: usersResult.data.users.edges,
    pagiInfo: usersResult.data.users.pageInfo
  })
}

export const useUserManagementLoaderData = () => useLoaderData<typeof loader>()

export default function UserManagement() {
  return null
}
