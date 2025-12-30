import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.highlightCodeBlocks()
  }

  highlightCodeBlocks() {
    const hljs = window.hljs
    if (!hljs) return

    this.element.querySelectorAll("pre code").forEach((block) => {
      hljs.highlightElement(block)
    })
  }
}
