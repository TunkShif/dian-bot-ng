import { fromUnixTime } from "date-fns"
import { atom } from "jotai"
import { atomEffect } from "jotai-effect"
import { atomWithStorage } from "jotai/utils"
import { Presence, Socket } from "phoenix"
import { throttle } from "radash"

export type OnlineUser = {
  id: string
  qid: string
  name: string
  onlineAt: Date
}

export type OnlineUserActivity = {
  id: string
  user: OnlineUser
  location: string
  mouseX: number
  mouseY: number
}

export const onlineUsersAtom = atom<OnlineUser[]>([])
export const onlineUserActivitiesAtom = atom<Record<string, OnlineUserActivity>>({})

export const showOnlineActivityAtom = atomWithStorage("showOnlineActivity", true)
export const showHistoryActivityAtom = atomWithStorage("showHistoryActivity", true)

export const createSetupTrackerEffect = (baseUrl: string, token: string) =>
  atomEffect((get, set) => {
    const socket = createSocket(baseUrl, token)
    const cancelActivityTracker = createActivityTracker(socket, (event) => {
      const users = get(onlineUsersAtom)
      const user = users.find((user) => user.id === event.id)

      if (user) {
        const activity = {
          ...event,
          user
        }
        set(onlineUserActivitiesAtom, (prev) => ({ ...prev, [user.id]: activity }))
      }
    })
    const cancelOnlineTracker = createOnlineTracker(socket, (users) => set(onlineUsersAtom, users))

    socket.connect()

    return () => {
      cancelActivityTracker()
      cancelOnlineTracker()
      socket.disconnect()
    }
  })

export const createSocket = (baseUrl: string, token: string) => {
  const socket = new Socket(`${baseUrl}/socket`, { params: { token } })
  return socket
}

export const createOnlineTracker = (socket: Socket, callback: (users: OnlineUser[]) => void) => {
  const channel = socket.channel("room")
  const presence = new Presence(channel)

  presence.onSync(() => {
    const users = presence.list(
      (key, { metas: [first], user }) =>
        ({
          id: key,
          qid: user.qid,
          name: user.name,
          onlineAt: fromUnixTime(first.online_at)
        }) as OnlineUser
    )
    callback(users)
  })

  channel.join()

  return () => channel.leave()
}

export const createActivityTracker = (
  socket: Socket,
  onEvent: (event: Omit<OnlineUserActivity, "user">) => void
) => {
  const channel = socket.channel("activity")

  const trackUserActivity = throttle({ interval: 2 * 1000 }, (event: MouseEvent) => {
    const location = window.location.pathname
    const mouseX = (event.pageX / window.innerWidth) * 100
    const mouseY = (event.pageY / window.innerHeight) * 100

    channel.push("move", { location, mouseX, mouseY })
  })

  window.addEventListener("mousemove", trackUserActivity)

  channel.on("new_move", (payload) => onEvent(payload))
  channel.join()

  return () => {
    window.removeEventListener("mousemove", trackUserActivity)
    channel.leave()
  }
}
