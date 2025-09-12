/**
 * Gestión de Slots - Interacciones JavaScript
 * Maneja búsqueda, filtrado, asignación y drag & drop de usuarios en slots
 */

class SlotsManager {
  constructor() {
    this.init();
  }

  init() {
    this.bindEvents();
    this.setupDragAndDrop();
    this.loadInitialData();
  }

  /**
   * Vincula eventos de DOM
   */
  bindEvents() {
    // Búsqueda en tiempo real
    const searchInput = document.getElementById('user-search');
    if (searchInput) {
      searchInput.addEventListener('input', this.debounce(this.handleSearch.bind(this), 300));
    }

    // Filtros de especialidad
    const specialtyFilter = document.getElementById('specialty-filter');
    if (specialtyFilter) {
      specialtyFilter.addEventListener('change', this.handleSpecialtyFilter.bind(this));
    }

    // Toggle del panel lateral
    const panelToggle = document.querySelector('[data-toggle="search-panel"]');
    if (panelToggle) {
      panelToggle.addEventListener('click', this.toggleSearchPanel.bind(this));
    }

    // Botones de limpiar filtros
    const clearFiltersBtn = document.getElementById('clear-filters');
    if (clearFiltersBtn) {
      clearFiltersBtn.addEventListener('click', this.clearAllFilters.bind(this));
    }

    // Click en slots vacíos para mostrar panel de asignación
    document.querySelectorAll('.slot-empty').forEach(slot => {
      slot.addEventListener('click', this.handleEmptySlotClick.bind(this));
    });

    // Botones de desasignar usuario
    document.querySelectorAll('[data-action="unassign"]').forEach(btn => {
      btn.addEventListener('click', this.handleUnassignUser.bind(this));
    });
  }

  /**
   * Configura funcionalidad drag & drop
   */
  setupDragAndDrop() {
    // Hacer usuarios arrastrables
    document.querySelectorAll('.user-card[draggable="true"]').forEach(card => {
      card.addEventListener('dragstart', this.handleDragStart.bind(this));
      card.addEventListener('dragend', this.handleDragEnd.bind(this));
    });

    // Configurar slots como drop zones
    document.querySelectorAll('.slot-card').forEach(slot => {
      slot.addEventListener('dragover', this.handleDragOver.bind(this));
      slot.addEventListener('drop', this.handleDrop.bind(this));
      slot.addEventListener('dragenter', this.handleDragEnter.bind(this));
      slot.addEventListener('dragleave', this.handleDragLeave.bind(this));
    });

    // Configurar panel lateral como drop zone para desasignar
    const usersList = document.getElementById('users-list');
    if (usersList) {
      usersList.addEventListener('dragover', this.handleDragOver.bind(this));
      usersList.addEventListener('drop', this.handleDropToUnassign.bind(this));
    }
  }

  /**
   * Carga datos iniciales
   */
  loadInitialData() {
    this.loadAvailableUsers();
    this.updateSlotsCounter();
  }

  /**
   * Maneja búsqueda de usuarios en tiempo real
   */
  async handleSearch(event) {
    const query = event.target.value.trim();
    const specialty = document.getElementById('specialty-filter')?.value || '';
    
    this.showLoadingState();
    
    try {
      const users = await this.searchUsers(query, specialty);
      this.renderUsersList(users);
    } catch (error) {
      this.showError('Error al buscar usuarios: ' + error.message);
    } finally {
      this.hideLoadingState();
    }
  }

  /**
   * Maneja filtro por especialidad
   */
  async handleSpecialtyFilter(event) {
    const specialty = event.target.value;
    const query = document.getElementById('user-search')?.value || '';
    
    this.showLoadingState();
    
    try {
      const users = await this.searchUsers(query, specialty);
      this.renderUsersList(users);
    } catch (error) {
      this.showError('Error al filtrar usuarios: ' + error.message);
    } finally {
      this.hideLoadingState();
    }
  }

  /**
   * Busca usuarios via API
   */
  async searchUsers(query = '', specialty = '') {
    const params = new URLSearchParams();
    if (query) params.append('q', query);
    if (specialty) params.append('specialty', specialty);
    
    const response = await fetch(`/projects/${this.getProjectId()}/search_users?${params}`, {
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': this.getCSRFToken()
      }
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    return await response.json();
  }

  /**
   * Carga usuarios disponibles inicialmente
   */
  async loadAvailableUsers() {
    try {
      const users = await this.searchUsers();
      this.renderUsersList(users);
    } catch (error) {
      this.showError('Error al cargar usuarios: ' + error.message);
    }
  }

  /**
   * Renderiza la lista de usuarios
   */
  renderUsersList(users) {
    const container = document.getElementById('users-list');
    if (!container) return;

    if (users.length === 0) {
      container.innerHTML = `
        <div class="text-center py-8 text-slate-500">
          <i class="fas fa-user-slash text-2xl mb-2 opacity-50"></i>
          <p class="text-sm">No se encontraron usuarios</p>
        </div>
      `;
      return;
    }

    container.innerHTML = users.map(user => `
      <div class="user-card p-3 border border-slate-200 rounded-lg hover:border-blue-300 hover:shadow-sm transition-all duration-200 cursor-grab active:cursor-grabbing"
           draggable="true"
           data-user-id="${user.id}"
           data-user-name="${this.escapeHtml(user.full_name)}"
           data-user-specialty="${this.escapeHtml(user.specialty || '')}">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-full flex items-center justify-center text-white font-semibold text-sm">
            ${this.getUserInitials(user.full_name)}
          </div>
          <div class="flex-1 min-w-0">
            <h4 class="font-medium text-slate-900 text-sm truncate">${this.escapeHtml(user.full_name)}</h4>
            ${user.specialty ? `<p class="text-xs text-slate-500 truncate">${this.escapeHtml(user.specialty)}</p>` : ''}
            ${user.location ? `<p class="text-xs text-slate-400 truncate"><i class="fas fa-map-marker-alt mr-1"></i>${this.escapeHtml(user.location)}</p>` : ''}
          </div>
          <div class="flex flex-col items-end gap-1">
            <button class="assign-user-btn px-3 py-1 bg-blue-500 hover:bg-blue-600 text-white text-xs rounded-full transition-colors"
                    data-user-id="${user.id}"
                    title="Asignar a slot">
              <i class="fas fa-plus mr-1"></i>Asignar
            </button>
          </div>
        </div>
      </div>
    `).join('');

    // Re-bind eventos para nuevos elementos
    this.bindUserCardEvents();
  }

  /**
   * Vincula eventos para las tarjetas de usuario
   */
  bindUserCardEvents() {
    // Drag and drop para nuevas tarjetas
    document.querySelectorAll('.user-card[draggable="true"]').forEach(card => {
      card.addEventListener('dragstart', this.handleDragStart.bind(this));
      card.addEventListener('dragend', this.handleDragEnd.bind(this));
    });

    // Botones de asignar
    document.querySelectorAll('.assign-user-btn').forEach(btn => {
      btn.addEventListener('click', this.handleAssignClick.bind(this));
    });
  }

  /**
   * Maneja click en botón de asignar
   */
  async handleAssignClick(event) {
    event.stopPropagation();
    const userId = event.target.closest('[data-user-id]').dataset.userId;
    
    // Buscar primer slot vacío
    const emptySlot = document.querySelector('.slot-empty');
    if (emptySlot) {
      await this.assignUserToSlot(userId, emptySlot.dataset.slotId);
    } else {
      this.showError('No hay slots disponibles');
    }
  }

  /**
   * Maneja inicio de arrastre
   */
  handleDragStart(event) {
    const card = event.target.closest('.user-card');
    event.dataTransfer.setData('application/json', JSON.stringify({
      userId: card.dataset.userId,
      userName: card.dataset.userName,
      userSpecialty: card.dataset.userSpecialty,
      source: 'users-panel'
    }));
    
    card.classList.add('opacity-50');
    document.body.classList.add('dragging');
  }

  /**
   * Maneja fin de arrastre
   */
  handleDragEnd(event) {
    event.target.classList.remove('opacity-50');
    document.body.classList.remove('dragging');
    document.querySelectorAll('.slot-card').forEach(slot => {
      slot.classList.remove('drag-over');
    });
  }

  /**
   * Maneja arrastre sobre slots
   */
  handleDragOver(event) {
    event.preventDefault();
  }

  /**
   * Maneja entrada de arrastre en slot
   */
  handleDragEnter(event) {
    event.preventDefault();
    const slot = event.target.closest('.slot-card');
    if (slot && slot.classList.contains('slot-empty')) {
      slot.classList.add('drag-over');
    }
  }

  /**
   * Maneja salida de arrastre de slot
   */
  handleDragLeave(event) {
    const slot = event.target.closest('.slot-card');
    if (slot && !slot.contains(event.relatedTarget)) {
      slot.classList.remove('drag-over');
    }
  }

  /**
   * Maneja soltar en slot
   */
  async handleDrop(event) {
    event.preventDefault();
    const slot = event.target.closest('.slot-card');
    if (!slot) return;

    slot.classList.remove('drag-over');

    try {
      const data = JSON.parse(event.dataTransfer.getData('application/json'));
      
      if (slot.classList.contains('slot-empty')) {
        await this.assignUserToSlot(data.userId, slot.dataset.slotId);
      } else {
        this.showError('Este slot ya está ocupado');
      }
    } catch (error) {
      this.showError('Error al procesar la asignación: ' + error.message);
    }
  }

  /**
   * Maneja soltar en panel para desasignar
   */
  async handleDropToUnassign(event) {
    event.preventDefault();
    
    try {
      const data = JSON.parse(event.dataTransfer.getData('application/json'));
      
      if (data.source === 'slot') {
        await this.unassignUserFromSlot(data.userId, data.slotId);
      }
    } catch (error) {
      this.showError('Error al desasignar usuario: ' + error.message);
    }
  }

  /**
   * Maneja click en slot vacío
   */
  handleEmptySlotClick(event) {
    const slot = event.target.closest('.slot-card');
    if (!slot) return;

    // Abrir panel si está cerrado
    const searchPanel = document.getElementById('search-panel');
    if (searchPanel && searchPanel.classList.contains('hidden')) {
      this.toggleSearchPanel();
    }

    // Destacar slot seleccionado
    document.querySelectorAll('.slot-card').forEach(s => s.classList.remove('selected'));
    slot.classList.add('selected');

    // Enfocar búsqueda
    const searchInput = document.getElementById('user-search');
    if (searchInput) {
      searchInput.focus();
    }
  }

  /**
   * Maneja desasignación de usuario
   */
  async handleUnassignUser(event) {
    event.preventDefault();
    const btn = event.target.closest('[data-action="unassign"]');
    const slotCard = btn.closest('.slot-card');
    const userId = btn.dataset.userId;
    const slotId = slotCard.dataset.slotId;

    if (confirm('¿Estás seguro de que quieres desasignar a este usuario?')) {
      await this.unassignUserFromSlot(userId, slotId);
    }
  }

  /**
   * Asigna usuario a slot
   */
  async assignUserToSlot(userId, slotId) {
    this.showLoadingState();
    
    try {
      const response = await fetch(`/projects/${this.getProjectId()}/project_slots/${slotId}/assign`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({ user_id: userId })
      });

      const result = await response.json();

      if (response.ok) {
        this.showSuccess(result.message || 'Usuario asignado correctamente');
        await this.refreshSlot(slotId);
        await this.loadAvailableUsers(); // Refrescar lista de usuarios disponibles
        this.updateSlotsCounter();
      } else {
        throw new Error(result.error || 'Error al asignar usuario');
      }
    } catch (error) {
      this.showError('Error al asignar usuario: ' + error.message);
    } finally {
      this.hideLoadingState();
    }
  }

  /**
   * Desasigna usuario de slot
   */
  async unassignUserFromSlot(userId, slotId) {
    this.showLoadingState();
    
    try {
      const response = await fetch(`/projects/${this.getProjectId()}/project_slots/${slotId}/unassign`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({ user_id: userId })
      });

      const result = await response.json();

      if (response.ok) {
        this.showSuccess(result.message || 'Usuario desasignado correctamente');
        await this.refreshSlot(slotId);
        await this.loadAvailableUsers(); // Refrescar lista de usuarios disponibles
        this.updateSlotsCounter();
      } else {
        throw new Error(result.error || 'Error al desasignar usuario');
      }
    } catch (error) {
      this.showError('Error al desasignar usuario: ' + error.message);
    } finally {
      this.hideLoadingState();
    }
  }

  /**
   * Refresca un slot específico
   */
  async refreshSlot(slotId) {
    try {
      const response = await fetch(`/projects/${this.getProjectId()}/project_slots/${slotId}`, {
        headers: {
          'Accept': 'text/html',
          'X-CSRF-Token': this.getCSRFToken()
        }
      });

      if (response.ok) {
        const html = await response.text();
        const slotCard = document.querySelector(`[data-slot-id="${slotId}"]`);
        if (slotCard) {
          const tempDiv = document.createElement('div');
          tempDiv.innerHTML = html;
          const newSlotCard = tempDiv.querySelector('.slot-card');
          slotCard.outerHTML = newSlotCard.outerHTML;
          
          // Re-bind eventos para el nuevo slot
          this.bindSlotEvents(document.querySelector(`[data-slot-id="${slotId}"]`));
        }
      }
    } catch (error) {
      console.error('Error al refrescar slot:', error);
    }
  }

  /**
   * Vincula eventos para un slot específico
   */
  bindSlotEvents(slot) {
    if (!slot) return;

    // Eventos de drag & drop
    slot.addEventListener('dragover', this.handleDragOver.bind(this));
    slot.addEventListener('drop', this.handleDrop.bind(this));
    slot.addEventListener('dragenter', this.handleDragEnter.bind(this));
    slot.addEventListener('dragleave', this.handleDragLeave.bind(this));

    // Click en slot vacío
    if (slot.classList.contains('slot-empty')) {
      slot.addEventListener('click', this.handleEmptySlotClick.bind(this));
    }

    // Botones de desasignar
    slot.querySelectorAll('[data-action="unassign"]').forEach(btn => {
      btn.addEventListener('click', this.handleUnassignUser.bind(this));
    });
  }

  /**
   * Toggle del panel lateral
   */
  toggleSearchPanel() {
    const panel = document.getElementById('search-panel');
    const overlay = document.getElementById('panel-overlay');
    
    if (panel && overlay) {
      const isHidden = panel.classList.contains('hidden');
      
      if (isHidden) {
        panel.classList.remove('hidden');
        overlay.classList.remove('hidden');
        setTimeout(() => {
          panel.classList.remove('translate-x-full');
          overlay.classList.remove('opacity-0');
        }, 10);
      } else {
        panel.classList.add('translate-x-full');
        overlay.classList.add('opacity-0');
        setTimeout(() => {
          panel.classList.add('hidden');
          overlay.classList.add('hidden');
        }, 300);
      }
    }
  }

  /**
   * Limpia todos los filtros
   */
  clearAllFilters() {
    const searchInput = document.getElementById('user-search');
    const specialtyFilter = document.getElementById('specialty-filter');
    
    if (searchInput) searchInput.value = '';
    if (specialtyFilter) specialtyFilter.value = '';
    
    this.loadAvailableUsers();
  }

  /**
   * Actualiza contador de slots
   */
  updateSlotsCounter() {
    const totalSlots = document.querySelectorAll('.slot-card').length;
    const occupiedSlots = document.querySelectorAll('.slot-card:not(.slot-empty)').length;
    const emptySlots = totalSlots - occupiedSlots;

    const counter = document.getElementById('slots-counter');
    if (counter) {
      counter.innerHTML = `
        <div class="text-sm text-slate-600">
          <span class="font-medium">${occupiedSlots}</span> de <span class="font-medium">${totalSlots}</span> ocupados
          <span class="ml-2 px-2 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-medium">
            ${emptySlots} disponibles
          </span>
        </div>
      `;
    }
  }

  /**
   * Estados de loading y mensajes
   */
  showLoadingState() {
    const container = document.getElementById('users-list');
    if (container) {
      container.innerHTML = `
        <div class="text-center py-8 text-slate-500">
          <div class="animate-spin w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full mx-auto mb-2"></div>
          <p class="text-sm">Cargando...</p>
        </div>
      `;
    }
  }

  hideLoadingState() {
    // Loading se oculta automáticamente al renderizar resultados
  }

  showSuccess(message) {
    this.showNotification(message, 'success');
  }

  showError(message) {
    this.showNotification(message, 'error');
  }

  showNotification(message, type = 'info') {
    // Crear contenedor de notificaciones si no existe
    let container = document.getElementById('notifications-container');
    if (!container) {
      container = document.createElement('div');
      container.id = 'notifications-container';
      container.className = 'fixed top-4 right-4 z-50 space-y-2';
      document.body.appendChild(container);
    }

    // Crear notificación
    const notification = document.createElement('div');
    const bgColors = {
      success: 'bg-green-500',
      error: 'bg-red-500',
      info: 'bg-blue-500'
    };
    
    notification.className = `${bgColors[type]} text-white px-4 py-2 rounded-lg shadow-lg transform translate-x-full transition-transform duration-300`;
    notification.innerHTML = `
      <div class="flex items-center gap-2">
        <i class="fas fa-${type === 'success' ? 'check' : type === 'error' ? 'exclamation-triangle' : 'info-circle'}"></i>
        <span class="text-sm font-medium">${message}</span>
      </div>
    `;

    container.appendChild(notification);

    // Mostrar con animación
    setTimeout(() => notification.classList.remove('translate-x-full'), 100);

    // Auto-ocultar después de 4 segundos
    setTimeout(() => {
      notification.classList.add('translate-x-full');
      setTimeout(() => notification.remove(), 300);
    }, 4000);
  }

  /**
   * Utilidades
   */
  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }

  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  getUserInitials(fullName) {
    return fullName
      .split(' ')
      .map(name => name.charAt(0).toUpperCase())
      .slice(0, 2)
      .join('');
  }

  getProjectId() {
    // Obtener ID del proyecto desde la URL o atributo data
    const pathParts = window.location.pathname.split('/');
    const projectIndex = pathParts.indexOf('projects');
    return projectIndex !== -1 ? pathParts[projectIndex + 1] : null;
  }

  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
  }
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
  // Solo inicializar si estamos en la página de slots
  if (document.querySelector('.slots-container')) {
    new SlotsManager();
  }
});

// Exportar para uso en otros módulos si es necesario
if (typeof module !== 'undefined' && module.exports) {
  module.exports = SlotsManager;
}
