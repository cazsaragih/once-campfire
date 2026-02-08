import { Controller } from "@hotwired/stimulus"
import { cable } from "@hotwired/turbo-rails"

export default class extends Controller {
  async connect() {
    this.channel = await cable.subscribeTo({ channel: "AvailabilityChannel" }, {
      received: this.#update.bind(this)
    })
  }

  disconnect() {
    this.channel?.unsubscribe()
    this.channel = null
  }

  #update({ userId, availability }) {
    const avatars = this.element.querySelectorAll(`[data-user-id="${userId}"]`)
    avatars.forEach(avatar => {
      avatar.classList.remove("avatar--online", "avatar--away")
      avatar.classList.add(`avatar--${availability}`)
    })
  }
}
