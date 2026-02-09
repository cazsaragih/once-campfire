import { Controller } from "@hotwired/stimulus"
import huddleManager from "models/huddle_manager"

// Global floating indicator shown when user is in a call but navigated to a different room.
export default class extends Controller {
  static targets = ["roomName", "returnBtn"]

  connect() {
    this.unsubscribe = huddleManager.subscribe(() => this.#updateVisibility())
    this.#updateVisibility()
  }

  disconnect() {
    this.unsubscribe?.()
  }

  returnToCall() {
    if (huddleManager.roomId) {
      window.Turbo.visit(`/rooms/${huddleManager.roomId}`)
    }
  }

  async leave() {
    const roomId = huddleManager.roomId
    if (!roomId) return

    try {
      await huddleManager.leave({
        callsUrl: `/rooms/${roomId}/calls`,
        csrfToken: document.querySelector("meta[name='csrf-token']")?.content
      })
    } catch (error) {
      console.error("Failed to leave huddle:", error)
    }
  }

  #updateVisibility() {
    const inCall = huddleManager.inCall
    const currentRoomId = Current.room?.id
    const callRoomId = huddleManager.roomId

    // Show indicator only when in a call and viewing a different room
    const shouldShow = inCall && callRoomId && currentRoomId !== callRoomId

    this.element.hidden = !shouldShow

    if (shouldShow && this.hasRoomNameTarget) {
      this.roomNameTarget.textContent = `In a huddle`
    }
  }
}
