import { Controller } from "@hotwired/stimulus"
import huddleManager from "models/huddle_manager"

// Thin controller for the call banner's Join/Leave buttons.
// Delegates to the shared HuddleManager singleton.
export default class extends Controller {
  static values = { callsUrl: String }

  async join() {
    try {
      await huddleManager.join({
        callsUrl: this.callsUrlValue,
        csrfToken: this.#csrfToken
      })
    } catch (error) {
      console.error("Failed to join huddle from banner:", error)
    }
  }

  async leave() {
    try {
      await huddleManager.leave({
        callsUrl: this.callsUrlValue,
        csrfToken: this.#csrfToken
      })
    } catch (error) {
      console.error("Failed to leave huddle from banner:", error)
    }
  }

  get #csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
