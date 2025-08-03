import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropArea", "fileInput", "preview"]

  connect() {
    this.setupDropArea()
    this.setupFileInput()
  }

  setupDropArea() {
    const dropArea = this.dropAreaTarget

    // Prevenir comportamiento por defecto
    ;['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      dropArea.addEventListener(eventName, this.preventDefaults, false)
      document.body.addEventListener(eventName, this.preventDefaults, false)
    })

    // Highlight drop area when item is dragged over it
    ;['dragenter', 'dragover'].forEach(eventName => {
      dropArea.addEventListener(eventName, () => this.highlight(dropArea), false)
    })

    ;['dragleave', 'drop'].forEach(eventName => {
      dropArea.addEventListener(eventName, () => this.unhighlight(dropArea), false)
    })

    // Handle dropped files
    dropArea.addEventListener('drop', this.handleDrop.bind(this), false)
    
    // Handle click to open file selector
    dropArea.addEventListener('click', () => this.fileInputTarget.click())
  }

  setupFileInput() {
    this.fileInputTarget.addEventListener('change', this.handleFiles.bind(this))
  }

  preventDefaults(e) {
    e.preventDefault()
    e.stopPropagation()
  }

  highlight(dropArea) {
    dropArea.classList.add('border-blue-400', 'bg-blue-50')
  }

  unhighlight(dropArea) {
    dropArea.classList.remove('border-blue-400', 'bg-blue-50')
  }

  handleDrop(e) {
    const dt = e.dataTransfer
    const files = dt.files
    this.fileInputTarget.files = files
    this.handleFiles({ target: { files } })
  }

  handleFiles(e) {
    const files = [...e.target.files]
    this.previewFiles(files)
  }

  previewFiles(files) {
    files.forEach(this.previewFile.bind(this))
  }

  previewFile(file) {
    const reader = new FileReader()
    reader.readAsDataURL(file)
    reader.onloadend = () => {
      const img = document.createElement('img')
      img.src = reader.result
      img.classList.add('w-24', 'h-24', 'object-cover', 'rounded-lg', 'border')
      this.previewTarget.appendChild(img)
    }
  }
}
