import { parseWithZod } from "@conform-to/zod"
import type { LoaderFunctionArgs } from "@remix-run/cloudflare"
import invariant from "tiny-invariant"
import { z } from "zod"

const schema = z.object({
  type: z.enum(["user", "group"]).default("user"),
  size: z.number().default(640)
})

export const loader = async ({ request, params }: LoaderFunctionArgs) => {
  const searchParams = new URL(request.url).searchParams
  const submission = parseWithZod(searchParams, { schema })

  if (submission.status !== "success") {
    return new Response("Invalid arguments.", { status: 400 })
  }

  const id = params.id
  const { type, size } = submission.value
  invariant(id, "Avatar id is missing")

  let url = ""
  switch (type) {
    case "user":
      url = `https://q1.qlogo.cn/g?b=qq&nk=${id}&s=${size}`
      break
    case "group":
      url = `https://p.qlogo.cn/gh/${id}/${id}/${size}/`
      break
  }

  return fetch(url)
}
