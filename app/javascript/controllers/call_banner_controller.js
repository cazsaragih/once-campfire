import { Controller } from "@hotwired/stimulus"
import mingleManager from "models/mingle_manager"

// Thin controller for the call banner's Join/Leave buttons.
// Delegates to the shared MingleManager singleton.
export default class extends Controller {
  static values = { callsUrl: String }

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

  get #csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
