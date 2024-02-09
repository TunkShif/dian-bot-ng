import { Elysia, t } from "elysia"

import forwarded_messages from "./data/forwarded_messages.json"
import groups from "./data/groups.json"
import messages from "./data/messages.json"
import users from "./data/users.json"

export const Res = {
  ok: <T>(data: T) => ({ status: "ok", data }),
  err: <T>(msg?: T) => ({ status: "failed", data: null, msg: msg ?? "not found" })
}

const okOrError = <T>(data: T) => (data ? Res.ok(data) : Res.err())

const app = new Elysia()
  .onRequest(({ request }) => {
    const url = new URL(request.url)
    console.log(`[${new Date().toLocaleString()}] ${request.method} ${url.pathname}${url.search}`)
  })
  .group("/bot", (app) =>
    app
      .get("/get_status", () => Res.ok({ online: Math.random() > 0.5 }))
      .get(
        "/get_stranger_info",
        ({ query: { user_id } }) => okOrError(users.find((it) => it.qid.toString() === user_id)),
        {
          query: t.Object({ user_id: t.String() })
        }
      )
      .get(
        "/get_group_info",
        ({ query: { group_id } }) => okOrError(groups.find((it) => it.gid.toString() === group_id)),
        {
          query: t.Object({ group_id: t.String() })
        }
      )
      .get(
        "/get_msg",
        ({ query: { message_id } }) => okOrError(messages[(parseInt(message_id) ?? 0) - 1]),
        {
          query: t.Object({ message_id: t.String() })
        }
      )
      .get(
        "/get_forward_msg",
        ({ query: { message_id } }) => {
          const messages = forwarded_messages[(parseInt(message_id) ?? 0) - 1]
          return okOrError(messages && { messages })
        },
        {
          query: t.Object({ message_id: t.String() })
        }
      )
      .post("/send_group_msg", () => Res.ok(null))
      .post("/set_essence_msg", () => Res.ok(null))
  )
  .group("/storage", (app) =>
    app
      .get(
        "/storage/v1/object/public/:bucket/:name",
        async ({ params: { name } }) => Bun.file(`./public/images/${name}`),
        {
          params: t.Object({ bucket: t.String(), name: t.String() })
        }
      )
      .get(
        "/storage/v1/object/info/public/:bucket/:name",
        async ({ params: { name }, set }) => {
          const file = Bun.file(`./public/images/${name}`)
          if (await file.exists()) {
            return Res.ok(null)
          } else {
            set.status = "Not Found"
            return Res.err()
          }
        },
        {
          params: t.Object({ bucket: t.String(), name: t.String() })
        }
      )
      .post(
        "/storage/v1/object/:bucket/:name",
        async ({ params: { name }, body: { file } }) => {
          await Bun.write(Bun.file(`./public/images/${name}`), file)
          return Res.ok(null)
        },
        {
          params: t.Object({ bucket: t.String(), name: t.String() }),
          body: t.Object({ file: t.File() })
        }
      )
  )

app.listen(4320)

console.log(`🦊 Elysia is running at ${app.server?.hostname}:${app.server?.port}`)
