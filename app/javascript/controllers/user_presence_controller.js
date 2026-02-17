import { Controller } from "@hotwired/stimulus"
import { cable } from "@hotwired/turbo-rails"

const HEARTBEAT_INTERVAL = 50 * 1000

export default class extends Controller {
  async connect() {
    this.channel = await cable.subscribeTo(
      { channel: "UserPresenceChannel" },
      {
        connected: this.#websocketConnected,
        disconnected: this.#websocketDisconnected,
        received: this.#handleBroadcast.bind(this)
      }
    )
  }

  disconnect() {
    this.#stopHeartbeat()
    this.channel?.unsubscribe()
    this.channel = null
  }

  #websocketConnected = () => {
    this.#startHeartbeat()
  }

  #websocketDisconnected = () => {
    this.#stopHeartbeat()
  }

  #startHeartbeat() {
    this.heartbeatTimer ??= setInterval(() => {
      this.channel.perform("heartbeat")
    }, HEARTBEAT_INTERVAL)
  }

  #stopHeartbeat() {
    clearInterval(this.heartbeatTimer)
    this.heartbeatTimer = null
  }

  #handleBroadcast({ userId, availability }) {
    const avatars = document.querySelectorAll(`[data-user-id="${userId}"]`)
    avatars.forEach(avatar => {
      avatar.classList.remove("avatar--online", "avatar--away")
      avatar.classList.add(`avatar--${availability}`)
    })
  }
}
