import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    console.log("Consent controller connected");
    console.log("User logged in:", window.currentUserLoggedIn);
    
    if (this.hasAccepted()) {
      console.log("User has already accepted, hiding banner");
      this.element.classList.add('hidden');
    } else {
      console.log("User has not accepted, showing banner");
      this.element.classList.remove('hidden');
    }
  }

  hasAccepted() {
    if (window.currentUserLoggedIn) {
      // Lógica para usuarios registrados (la manejas en el backend)
      // El helper `show_consent_banner?` debería devolver false si ya aceptaron.
      // Este chequeo es por si el banner se muestra antes de que el backend lo oculte.
      return false; // Asumimos que si se muestra, es porque el backend lo decidió.
    } else {
      // Lógica para invitados usando cookies
      const consentCookie = document.cookie.split('; ').find(row => row.startsWith('consent_preferences='));
      if (!consentCookie) return false;

      const consentData = JSON.parse(consentCookie.split('=')[1]);
      const consentVersion = this.element.dataset.consentVersionValue;
      
      // Comprobar si la versión del consentimiento en la cookie es la misma que la actual
      return consentData.version && consentData.version.toString() === consentVersion;
    }
  }

  customize() {
    this.modalTarget.classList.remove('hidden');
  }

  closeModal() {
    this.modalTarget.classList.add('hidden');
  }

  acceptAll() {
    console.log("Accept all clicked");
    const preferences = {
      analytics: true,
      marketing: true
    };
    this.saveAndClose(preferences);
  }

  rejectAll() {
    const preferences = {
      analytics: false,
      marketing: false
    };
    this.saveAndClose(preferences);
  }

  savePreferences(event) {
    event.preventDefault();
    const preferences = {};
    const formData = new FormData(event.target);
    
    // Inicializamos con false para asegurar que los no marcados se guarden como tal
    preferences['analytics'] = false;
    preferences['marketing'] = false;

    for (let [key, value] of formData.entries()) {
      preferences[key] = value === 'on'; // 'on' es el valor de un checkbox marcado sin `value`
    }
    
    this.saveAndClose(preferences);
  }

  saveAndClose(preferences) {
    const consentVersion = this.element.dataset.consentVersionValue;
    const data = {
      version: consentVersion,
      preferences: preferences
    };

    if (!window.currentUserLoggedIn) {
      document.cookie = `consent_preferences=${JSON.stringify(data)}; path=/; max-age=${60*60*24*365}`;
    } else {
      fetch('/consent_banner/accept', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({ consent: data })
      });
    }

    this.element.classList.add('hidden');
    this.closeModal();
  }
}

