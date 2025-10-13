// Función para confirmar y realizar logout
function confirmarLogout() {
    if (confirm('¿Estás seguro de que deseas cerrar sesión?')) {
        // Agregar timestamp para evitar cache
        var timestamp = new Date().getTime();
        window.location.href = '../../logout.jsp?t=' + timestamp;
        return false; // Prevenir navegación normal
    }
    return false; // Cancelar si el usuario no confirma
}

// Prevenir cache del navegador
window.onload = function() {
    if (performance.navigation.type === 2) {
        // Si viene del cache, recargar
        location.reload(true);
    }
};