import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle() {
    const currentTheme = document.documentElement.style.colorScheme;
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    
    document.documentElement.style.colorScheme = newTheme;
    localStorage.setItem('theme', newTheme);

    const moonIcon = this.element.querySelector('.moon-icon');
    const sunIcon = this.element.querySelector('.sun-icon');
    
    if (newTheme === 'dark') {
      moonIcon.style.display = 'none';
      sunIcon.style.display = 'block';
    } else {
      moonIcon.style.display = 'block';
      sunIcon.style.display = 'none';
    }
  }
}