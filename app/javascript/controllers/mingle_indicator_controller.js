import { Controller } from "@hotwired/stimulus"
import mingleManager from "models/mingle_manager"

// Global floating indicator shown when user is in a call but navigated to a different room.
export default class extends Controller {
  static targets = ["roomName", "returnBtn"]

  connect() {
    this.unsubscribe = mingleManager.subscribe(() => this.#updateVisibility())
    this.#updateVisibility()
  }

  disconnect() {
    this.unsubscribe?.()
  }

  returnToCall() {
    if (mingleManager.roomId) {
      window.Turbo.visit(`/rooms/${mingleManager.roomId}`)
    }
  }

  async leave() {
    const roomId = mingleManager.roomId
    if (!roomId) return

    try {
      await mingleManager.leave({
        callsUrl: `/rooms/${roomId}/calls`,
        csrfToken: document.querySelector("meta[name='csrf-token']")?.content
      })
    } catch (error) {
      console.error("Failed to leave mingle:", error)
    }
  }

  #updateVisibility() {
    const inCall = mingleManager.inCall
    const currentRoomId = Current.room?.id
    const callRoomId = mingleManager.roomId

    // Show indicator only when in a call and viewing a different room
    const shouldShow = inCall && callRoomId && currentRoomId !== callRoomId

    this.element.hidden = !shouldShow

    if (shouldShow && this.hasRoomNameTarget) {
      this.roomNameTarget.textContent = `In a mingle`
    }
  }
}
