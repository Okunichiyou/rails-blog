import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  #isOpen = false;
  #menu;
  #boundHandleClickOutside;

  connect() {
    this.#menu = this.element.parentElement.querySelector('.hamburger-menu');
    this.#boundHandleClickOutside = (event) => this.#handleClickOutside(event);
  }
  
  toggle() {
    this.#isOpen = !this.#isOpen;
    this.element.classList.toggle('open', this.#isOpen);
    this.#menu.classList.toggle('show', this.#isOpen);
    
    if (this.#isOpen) {
      document.addEventListener('click', this.#boundHandleClickOutside);
    }
  }

  disconnect() {
    document.removeEventListener('click', this.#boundHandleClickOutside);
  }
  
  #handleClickOutside(event) {
    if (!this.element.contains(event.target) && !this.#menu.contains(event.target)) {
      this.#close();
    }
  }
  
  #close() {
    this.#isOpen = false;
    this.element.classList.remove('open');
    this.#menu.classList.remove('show');
    document.removeEventListener('click', this.#boundHandleClickOutside);
  }
}