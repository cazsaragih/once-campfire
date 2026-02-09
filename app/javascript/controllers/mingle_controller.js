import { Controller } from "@hotwired/stimulus"
import mingleManager from "models/mingle_manager"

export default class extends Controller {
  static targets = ["toggleBtn", "controls", "muteBtn"]
  static values = {
    roomId: Number,
    callsUrl: String
  }

  connect() {
    this.unsubscribe = mingleManager.subscribe(() => this.#updateUI())
    this.#updateUI()
  }

  disconnect() {
    this.unsubscribe?.()
  }

  async toggle() {
    if (mingleManager.inCall) {
      await this.leave()
    } else {
      await this.join()
    }
  }

  async join() {
    try {
      await mingleManager.join({
        callsUrl: this.callsUrlValue,
        csrfToken: this.#csrfToken
      })
    } catch (error) {
      console.error("Failed to join mingle:", error)
    }
  }

  async leave() {
    try {
      await mingleManager.leave({
        callsUrl: this.callsUrlValue,
        csrfToken: this.#csrfToken
      })
    } catch (error) {
      console.error("Failed to leave mingle:", error)
    }
  }

  toggleMute() {
    mingleManager.toggleMute()
  }

  #updateUI() {
    const inCall = mingleManager.inCall
    const isCurrentRoom = mingleManager.roomId === this.roomIdValue

    if (this.hasToggleBtnTarget) {
      this.toggleBtnTarget.classList.toggle("btn--active-call", inCall && isCurrentRoom)
      this.toggleBtnTarget.title = inCall && isCurrentRoom ? "Leave mingle" : "Start a mingle"
    }

    if (this.hasControlsTarget) {
      this.controlsTarget.hidden = !(inCall && isCurrentRoom)
    }

    if (this.hasMuteBtnTarget) {
      this.muteBtnTarget.classList.toggle("mingle-controls__muted", mingleManager.muted)
      this.muteBtnTarget.title = mingleManager.muted ? "Unmute" : "Mute"
    }
  }

  get #csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
