import { parseWithZod } from "@conform-to/zod"
import {
  json,
  redirect,
  type ActionFunctionArgs,
  type LoaderFunctionArgs,
  type MetaFunction
} from "@remix-run/cloudflare"
import { Center, VStack } from "styled-system/jsx"
import invariant from "tiny-invariant"
import { createToast } from "~/lib/toast.server"
import { CreatePinnedMessageMutation } from "~/queries/create-pinned-message"
import { PinnedMessagesQuery } from "~/queries/pinned-messages"
import {
  SitePinnedMessage,
  schema as createPinnedMessageSchema
} from "~/routes/_app.admin.broadcast/site-pinned-message"

export const meta: MetaFunction = () => {
  return [{ title: "Broadcast - LITTLE RED BOOK" }]
}

export const schema = createPinnedMessageSchema

export const action = async ({ request, context }: ActionFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const formData = await request.formData()
  const submission = parseWithZod(formData, { schema })

  if (submission.status !== "success") {
    return submission.reply()
  }

  const createPinnedMessageResult = await client
    .mutation(CreatePinnedMessageMutation, submission.value)
    .toPromise()

  if (createPinnedMessageResult.data?.createPinnedMessage) {
    const headers = await createToast({
      type: "success",
      title: "创建成功",
      description: "成功发布一条新的公告"
    })
    return json(submission.reply({ resetForm: true }), { headers })
  }

  return submission.reply({ resetForm: true })
}

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const pinnedMessagesResult = await client.query(PinnedMessagesQuery, { first: 10 }).toPromise()
  invariant(pinnedMessagesResult.data)

  return json({ pinnedMessages: pinnedMessagesResult.data.pinnedMessages.edges })
}

export default function Broadcast() {
  return (
    <Center mx="4">
      <VStack w="full" maxW="3xl" py="4" lg={{ py: "8" }} gap="6">
        <SitePinnedMessage />
      </VStack>
    </Center>
  )
}
