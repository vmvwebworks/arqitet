import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "menu", "button", "area" ]

  connect() {
    this.boundHide = this.hide.bind(this)
    document.addEventListener("click", this.boundHide)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHide)
  }

  toggle(event) {
    event.stopPropagation()
    const isHidden = this.menuTarget.classList.contains("hidden")
    
    this.menuTarget.classList.toggle("hidden")
    
    // Toggle area active state with more visible highlighting
    if (isHidden) {
      // Opening dropdown - add active state
      this.setActiveState(true)
    } else {
      // Closing dropdown - remove active state
      this.setActiveState(false)
    }
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
      // Remove active state when closing
      this.setActiveState(false)
    }
  }

  setActiveState(isActive) {
    if (isActive) {
      // Add active styling - same color as hover but with more emphasis
      this.areaTarget.classList.add("bg-gray-100", "shadow-inner", "ring-1", "ring-gray-200")
      this.areaTarget.classList.remove("hover:bg-gray-100")
    } else {
      // Remove active styling
      this.areaTarget.classList.remove("bg-gray-100", "shadow-inner", "ring-1", "ring-gray-200")
      this.areaTarget.classList.add("hover:bg-gray-100")
    }
  }

  // Method to check if dropdown is open
  get isOpen() {
    return !this.menuTarget.classList.contains("hidden")
  }
}
