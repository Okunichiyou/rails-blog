import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const currentTheme = localStorage.getItem('theme') || 'light';
    
    document.documentElement.style.colorScheme = currentTheme;
    this.element.textContent = currentTheme === 'dark' ? '☀️' : '🌙';
  }
  
  toggle() {
    const currentTheme = document.documentElement.style.colorScheme;
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    
    document.documentElement.style.colorScheme = newTheme;
    localStorage.setItem('theme', newTheme);
    this.element.textContent = newTheme === 'dark' ? '☀️' : '🌙';
  }
}