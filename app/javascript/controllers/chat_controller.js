import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages"]

  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    const messagesContainer = this.messagesTarget
    messagesContainer.scrollTop = messagesContainer.scrollHeight
  }

  autoResize(event) {
    const textarea = event.target
    textarea.style.height = 'auto'
    const newHeight = Math.min(textarea.scrollHeight, 120) // Max 120px
    textarea.style.height = newHeight + 'px'
  }

  handleEnter(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      const form = event.target.closest('form')
      if (form && event.target.value.trim() !== '') {
        form.requestSubmit()
      }
    }
  }
}
