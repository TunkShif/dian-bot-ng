import { fromUnixTime } from "date-fns"
import { atom } from "jotai"
import { atomEffect } from "jotai-effect"
import { Presence, Socket } from "phoenix"
import { throttle } from "radash"

export const onlineUsersAtom = atom<OnlineUser[]>([])

export const createSetupTrackerEffect = (baseUrl: string, token: string) =>
  atomEffect((_get, set) => {
    const socket = createSocket(baseUrl, token)
    const cancelActivityTracker = createActivityTracker(socket)
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

export type OnlineUser = {
  id: string
  qid: string
  name: string
  onlineAt: Date
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

export const createActivityTracker = (socket: Socket) => {
  const channel = socket.channel("activity")

  const trackUserActivity = throttle({ interval: 5 * 1000 }, (event: MouseEvent) => {
    const location = window.location.pathname
    const mouseX = (event.pageX / window.innerWidth) * 100
    const mouseY = (event.pageY / window.innerHeight) * 100

    channel.push("move", { location, mouseX, mouseY })
  })

  window.addEventListener("mousemove", trackUserActivity)

  channel.join()

  return () => {
    window.removeEventListener("mousemove", trackUserActivity)
    channel.leave()
  }
}
