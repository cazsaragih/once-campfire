import { Controller } from "@hotwired/stimulus"
import { cable } from "@hotwired/turbo-rails"
import { delay } from "helpers/timing_helpers"

const HEARTBEAT_INTERVAL = 50 * 1000
const VISIBILITY_CHANGE_DELAY = 5000

export default class extends Controller {
  async connect() {
    this.wasVisible = document.visibilityState === "visible"

    this.channel = await cable.subscribeTo(
      { channel: "UserPresenceChannel", visible: this.wasVisible },
      {
        connected: this.#websocketConnected,
        disconnected: this.#websocketDisconnected,
        received: this.#handleBroadcast.bind(this)
      }
    )

    document.addEventListener("visibilitychange", this.#visibilityChanged)
  }

  disconnect() {
    this.#stopHeartbeat()
    document.removeEventListener("visibilitychange", this.#visibilityChanged)
    this.channel?.unsubscribe()
    this.channel = null
  }

  #websocketConnected = () => {
    this.connected = true
    if (this.wasVisible) this.#startHeartbeat()
  }

  #websocketDisconnected = () => {
    this.connected = false
    this.#stopHeartbeat()
  }

  #visibilityChanged = () => {
    if (document.visibilityState === "visible") {
      this.#onVisible()
    } else {
      this.#onHidden()
    }
  }

  #onVisible = async () => {
    await delay(VISIBILITY_CHANGE_DELAY)

    if (this.connected && document.visibilityState === "visible" && !this.wasVisible) {
      this.channel.perform("visible")
      this.#startHeartbeat()
      this.wasVisible = true
    }
  }

  #onHidden = async () => {
    await delay(VISIBILITY_CHANGE_DELAY)

    if (this.connected && this.wasVisible && document.visibilityState !== "visible") {
      this.channel.perform("hidden")
      this.#stopHeartbeat()
      this.wasVisible = false
    }
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
