<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
// Verificar autenticación y rol
String usuarioId = (String) session.getAttribute("usuario_id");
String usuarioRol = (String) session.getAttribute("usuario_rol");

if (usuarioId == null) {
    response.sendRedirect("../../login.jsp");
    return;
}

if (!"director".equals(usuarioRol)) {
    response.sendRedirect("../../dashboard.jsp?error=acceso_denegado");
    return;
}

// Obtener proyectos pendientes del director
java.util.ArrayList<String[]> proyectosPendientes = new java.util.ArrayList<>();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
        "unsp1ogkp7qbzhgm", 
        "ZXCRqDEJJIyGydtVjg3G"
    );
    
    String sql = "SELECT DISTINCT p.id, p.titulo, u.nombre as estudiante, u.email " +
                "FROM proyectos p " +
                "JOIN usuarios u ON p.estudiante_id = u.id " +
                "JOIN versiones_anteproyecto v ON p.id = v.proyecto_id " +
                "WHERE p.director_id = ? AND v.estado = 'pendiente'";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, usuarioId);
    ResultSet rs = pstmt.executeQuery();
    
    while (rs.next()) {
        String[] proyecto = {
            rs.getString("id"),
            rs.getString("titulo"),
            rs.getString("estudiante"),
            rs.getString("email")
        };
        proyectosPendientes.add(proyecto);
    }
    conn.close();
} catch (Exception e) {
    out.println("<!-- Error: " + e.getMessage() + " -->");
}

// Procesar calificación
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String proyectoId = request.getParameter("proyecto_id");
    String decision = request.getParameter("decision");
    String observaciones = request.getParameter("observaciones");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
            "unsp1ogkp7qbzhgm", 
            "ZXCRqDEJJIyGydtVjg3G"
        );
        
        // Actualizar estado de la versión
        String sqlVersion = "UPDATE versiones_anteproyecto SET estado = ?, observaciones = ? " +
                           "WHERE proyecto_id = ? AND estado = 'pendiente'";
        PreparedStatement pstmtVersion = conn.prepareStatement(sqlVersion);
        pstmtVersion.setString(1, decision);
        pstmtVersion.setString(2, observaciones);
        pstmtVersion.setString(3, proyectoId);
        pstmtVersion.executeUpdate();
        
        // Actualizar estado del proyecto
        String estadoProyecto = "correcciones";
        if ("aprobado".equals(decision)) {
            estadoProyecto = "aprobado";
        }
        
        String sqlProyecto = "UPDATE proyectos SET estado = ?, fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = ?";
        PreparedStatement pstmtProyecto = conn.prepareStatement(sqlProyecto);
        pstmtProyecto.setString(1, estadoProyecto);
        pstmtProyecto.setString(2, proyectoId);
        pstmtProyecto.executeUpdate();
        
        response.sendRedirect("dashboard.jsp?success=proyecto_calificado");
        return;
        
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>Error: " + e.getMessage() + "</div>");
    }
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calificar Proyecto - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <div class="form-container">
            <h2 style="text-align: center; color: var(--uts-red); margin-bottom: 30px;">⭐ Calificar Proyecto</h2>
            
            <% if (proyectosPendientes.isEmpty()) { %>
                <div class="alert alert-success">
                    <strong>✅ No hay proyectos pendientes de calificación</strong><br>
                    Todos los proyectos asignados han sido revisados.
                </div>
                <div style="text-align: center; margin-top: 20px;">
                    <a href="dashboard.jsp" class="btn btn-uts">🏠 Volver al Dashboard</a>
                </div>
            <% } else { %>
                <form method="POST" action="calificarProyecto.jsp">
                    <div class="form-group">
                        <label for="proyecto_id">Seleccionar Proyecto a Calificar:</label>
                        <select class="form-control" id="proyecto_id" name="proyecto_id" required 
                                onchange="cargarDetallesProyecto(this.value)">
                            <option value="">-- Selecciona un proyecto --</option>
                            <% for (String[] proyecto : proyectosPendientes) { %>
                                <option value="<%= proyecto[0] %>">
                                    <%= proyecto[1] %> - Estudiante: <%= proyecto[2] %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div id="detalles-proyecto" style="display: none; background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;">
                        <h4 style="color: var(--uts-red);">📋 Detalles del Proyecto</h4>
                        <div id="info-proyecto"></div>
                    </div>
                    
                    <div class="form-group">
                        <label>Decisi&#243;n:</label>
                        <div style="display: flex; gap: 15px; margin-top: 10px;">
                            <label style="display: flex; align-items: center; gap: 5px;">
                                <input type="radio" name="decision" value="aprobado" required> 
                                <span style="color: var(--uts-green); font-weight: bold;">✅ Aprobado</span>
                            </label>
                            <label style="display: flex; align-items: center; gap: 5px;">
                                <input type="radio" name="decision" value="rechazado" required> 
                                <span style="color: var(--uts-red); font-weight: bold;">❌ Rechazado</span>
                            </label>
                            <label style="display: flex; align-items: center; gap: 5px;">
                                <input type="radio" name="decision" value="correcciones" required> 
                                <span style="color: var(--uts-orange); font-weight: bold;">📝 Correcciones</span>
                            </label>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="observaciones">Observaciones y Comentarios:</label>
                        <textarea class="form-control" id="observaciones" name="observaciones" rows="6" 
                                  placeholder="Proporciona retroalimentación detallada al estudiante..."></textarea>
                    </div>
                    
                    <div style="text-align: center; margin-top: 30px;">
                        <button type="submit" class="btn btn-success">📝 Enviar Calificaci&#243;n</button>
                        <a href="dashboard.jsp" class="btn btn-uts">↩️ Cancelar</a>
                    </div>
                </form>
            <% } %>
        </div>
    </div>

    <script>
    function cargarDetallesProyecto(proyectoId) {
        if (!proyectoId) {
            document.getElementById('detalles-proyecto').style.display = 'none';
            return;
        }
        
        // Simular carga de detalles (en un sistema real harías una petición AJAX)
        document.getElementById('detalles-proyecto').style.display = 'block';
        document.getElementById('info-proyecto').innerHTML = `
            <p><strong>Proyecto seleccionado:</strong> Cargando detalles...</p>
            <p><strong>URL del anteproyecto:</strong> <a href="#" target="_blank">Ver documento</a></p>
            <p><strong>Versión actual:</strong> Pendiente de revisión</p>
        `;
    }
    </script>

    <%@ include file="../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>