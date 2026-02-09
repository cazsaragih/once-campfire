import { Controller } from "@hotwired/stimulus"
import huddleManager from "models/huddle_manager"

export default class extends Controller {
  static targets = ["toggleBtn", "controls", "muteBtn"]
  static values = {
    roomId: Number,
    callsUrl: String
  }

  connect() {
    this.unsubscribe = huddleManager.subscribe(() => this.#updateUI())
    this.#updateUI()
  }

  disconnect() {
    this.unsubscribe?.()
  }

  async toggle() {
    if (huddleManager.inCall) {
      await this.leave()
    } else {
      await this.join()
    }
  }

  async join() {
    try {
      await huddleManager.join({
        callsUrl: this.callsUrlValue,
        csrfToken: this.#csrfToken
      })
    } catch (error) {
      console.error("Failed to join huddle:", error)
    }
  }

  async leave() {
    try {
      await huddleManager.leave({
        callsUrl: this.callsUrlValue,
        csrfToken: this.#csrfToken
      })
    } catch (error) {
      console.error("Failed to leave huddle:", error)
    }
  }

  toggleMute() {
    huddleManager.toggleMute()
  }

  #updateUI() {
    const inCall = huddleManager.inCall
    const isCurrentRoom = huddleManager.roomId === this.roomIdValue

    if (this.hasToggleBtnTarget) {
      this.toggleBtnTarget.classList.toggle("btn--active-call", inCall && isCurrentRoom)
      this.toggleBtnTarget.title = inCall && isCurrentRoom ? "Leave huddle" : "Start a huddle"
    }

    if (this.hasControlsTarget) {
      this.controlsTarget.hidden = !(inCall && isCurrentRoom)
    }

    if (this.hasMuteBtnTarget) {
      this.muteBtnTarget.classList.toggle("huddle-controls__muted", huddleManager.muted)
      this.muteBtnTarget.title = huddleManager.muted ? "Unmute" : "Mute"
    }
  }

  get #csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
