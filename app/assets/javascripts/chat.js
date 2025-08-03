document.addEventListener('DOMContentLoaded', function() {
  const messagesContainer = document.getElementById('messages');
  
  // Scroll al final cuando se carga la página
  function scrollToBottom() {
    if (messagesContainer) {
      messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
  }
  
  // Scroll inicial
  scrollToBottom();
  
  // Scroll cuando llega un nuevo mensaje vía Turbo Stream
  document.addEventListener('turbo:frame-load', scrollToBottom);
  
  // Auto-resize del textarea
  const textarea = document.querySelector('#message_body');
  if (textarea) {
    textarea.addEventListener('input', function() {
      this.style.height = 'auto';
      this.style.height = Math.min(this.scrollHeight, 120) + 'px';
    });
    
    // Submit con Enter (Shift+Enter para nueva línea)
    textarea.addEventListener('keydown', function(e) {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        const form = this.closest('form');
        if (form && this.value.trim()) {
          form.requestSubmit();
        }
      }
    });
  }
});
