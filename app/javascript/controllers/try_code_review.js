import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textArea", "submitButton"]

  input(event) {
    const code = this.textAreaTarget.value.trim()
    this.submitButtonTarget.disabled = code === ""
  }
}
