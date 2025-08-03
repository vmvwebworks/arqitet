import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slides", "prevButton", "nextButton", "indicators"]
  
  connect() {
    this.currentSlide = 0
    this.totalSlides = this.indicatorsTargets.length
    this.updateButtons()
    console.log("Projects carousel connected with", this.totalSlides, "slides")
  }

  next() {
    if (this.currentSlide < this.totalSlides - 1) {
      this.currentSlide++
    } else {
      this.currentSlide = 0
    }
    this.updateCarousel()
  }

  previous() {
    if (this.currentSlide > 0) {
      this.currentSlide--
    } else {
      this.currentSlide = this.totalSlides - 1
    }
    this.updateCarousel()
  }

  goToSlide(event) {
    this.currentSlide = parseInt(event.target.dataset.slideIndex)
    this.updateCarousel()
  }

  updateCarousel() {
    const translateX = -this.currentSlide * 100
    this.slidesTarget.style.transform = `translateX(${translateX}%)`
    this.updateIndicators()
  }

  updateIndicators() {
    this.indicatorsTargets.forEach((indicator, index) => {
      if (index === this.currentSlide) {
        indicator.classList.remove('bg-gray-300')
        indicator.classList.add('bg-gray-600')
      } else {
        indicator.classList.remove('bg-gray-600')
        indicator.classList.add('bg-gray-300')
      }
    })
  }

  updateButtons() {
    if (this.totalSlides <= 1) {
      if (this.hasPrevButtonTarget) this.prevButtonTarget.style.display = 'none'
      if (this.hasNextButtonTarget) this.nextButtonTarget.style.display = 'none'
    } else {
      if (this.hasPrevButtonTarget) this.prevButtonTarget.style.display = 'block'
      if (this.hasNextButtonTarget) this.nextButtonTarget.style.display = 'block'
    }
  }
}
