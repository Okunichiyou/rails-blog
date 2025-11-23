import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  #isOpen = false;
  #menu;
  #lines;
  #boundHandleClickOutside;

  connect() {
    this.#menu = this.element.parentElement.querySelector('.hamburger-menu');
    this.#lines = this.element.querySelectorAll('.hamburger-line');
    this.#boundHandleClickOutside = (event) => this.#handleClickOutside(event);
  }

  toggle(event) {
    event.stopPropagation();
    this.#isOpen = !this.#isOpen;

    // メニューの表示/非表示
    this.#menu.classList.toggle('hidden', !this.#isOpen);
    this.#menu.classList.toggle('block', this.#isOpen);
    this.#menu.classList.toggle('shadow-[var(--shadow)]', this.#isOpen);

    // 3本の線のアニメーション
    if (this.#isOpen) {
      // ×マークにする (gap-1.5 = 6px + 線の高さ3px = 9px移動)
      this.#lines[0].classList.add('rotate-45', 'translate-y-[9px]');
      this.#lines[1].classList.add('opacity-0');
      this.#lines[2].classList.add('-rotate-45', '-translate-y-[9px]');
      document.addEventListener('click', this.#boundHandleClickOutside);
    } else {
      // 元の3本線に戻す
      this.#lines[0].classList.remove('rotate-45', 'translate-y-[9px]');
      this.#lines[1].classList.remove('opacity-0');
      this.#lines[2].classList.remove('-rotate-45', '-translate-y-[9px]');
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
    this.#menu.classList.add('hidden');
    this.#menu.classList.remove('block', 'shadow-[var(--shadow)]');
    this.#lines[0].classList.remove('rotate-45', 'translate-y-[9px]');
    this.#lines[1].classList.remove('opacity-0');
    this.#lines[2].classList.remove('-rotate-45', '-translate-y-[9px]');
    document.removeEventListener('click', this.#boundHandleClickOutside);
  }
}