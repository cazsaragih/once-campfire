import { Controller } from "@hotwired/stimulus"
import mingleManager from "models/mingle_manager"

// Controller for the call banner's Join/Leave buttons.
// Manages button visibility client-side based on MingleManager state,
// since Turbo Stream broadcasts don't have access to Current.user.
export default class extends Controller {
  static targets = ["joinBtn", "leaveBtn"]
  static values = { callsUrl: String, roomId: Number }

  connect() {
    this.unsubscribe = mingleManager.subscribe(() => this.#updateButton())
    this.#updateButton()
  }

  disconnect() {
    this.unsubscribe?.()
  }

  async join() {
    try {
      await mingleManager.join({
        callsUrl: this.callsUrlValue,
        csrfToken: this.#csrfToken
      })
    } catch (error) {
      console.error("Failed to join mingle from banner:", error)
    }
  }

  async leave() {
    try {
      await mingleManager.leave({
        callsUrl: this.callsUrlValue,
        csrfToken: this.#csrfToken
      })
    } catch (error) {
      console.error("Failed to leave mingle from banner:", error)
    }
  }

  #updateButton() {
    const inThisCall = mingleManager.inCall && mingleManager.roomId === this.roomIdValue

    if (this.hasLeaveBtnTarget) this.leaveBtnTarget.hidden = !inThisCall
    if (this.hasJoinBtnTarget) this.joinBtnTarget.hidden = inThisCall
  }

  get #csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
