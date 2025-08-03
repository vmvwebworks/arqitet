import { Controller } from "@hotwired/stimulus"
import { Splide } from "@splidejs/splide"

// Controlador de carrusel usando Splide.js
export default class extends Controller {
  connect() {
    console.log("Carousel controller connected (Splide enabled)")
    this.initSplide()
  }

  disconnect() {
    console.log("Carousel controller disconnected")
    if (this.splide) {
      this.splide.destroy()
    }
  }

  initSplide() {
    this.splide = new Splide(this.element, {
      type: 'loop',
      perPage: 1,
      autoplay: true,
      interval: 3000,
      pauseOnHover: true,
      arrows: true,
      pagination: true,
      height: '24rem', // 384px equivalente a h-96
      cover: true
    })

    this.splide.mount()
  }
}
