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

if (!"evaluador".equals(usuarioRol)) {
    response.sendRedirect("../../dashboard.jsp?error=acceso_denegado");
    return;
}

// Obtener proyectos asignados para evaluación
java.util.ArrayList<String[]> proyectosEvaluacion = new java.util.ArrayList<>();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
        "unsp1ogkp7qbzhgm", 
        "ZXCRqDEJJIyGydtVjg3G"
    );
    
    String sql = "SELECT p.id, p.titulo, e.nombre as estudiante, d.nombre as director, p.descripcion " +
                "FROM proyectos p " +
                "JOIN usuarios e ON p.estudiante_id = e.id " +
                "JOIN usuarios d ON p.director_id = d.id " +
                "WHERE p.evaluador_id = ? AND p.estado = 'evaluacion'";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, usuarioId);
    ResultSet rs = pstmt.executeQuery();
    
    while (rs.next()) {
        String[] proyecto = {
            rs.getString("id"),
            rs.getString("titulo"),
            rs.getString("estudiante"),
            rs.getString("director"),
            rs.getString("descripcion")
        };
        proyectosEvaluacion.add(proyecto);
    }
    conn.close();
} catch (Exception e) {
    out.println("<!-- Error: " + e.getMessage() + " -->");
}

// Procesar evaluación
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String proyectoId = request.getParameter("proyecto_id");
    String calificacion = request.getParameter("calificacion");
    String observaciones = request.getParameter("observaciones");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
            "unsp1ogkp7qbzhgm", 
            "ZXCRqDEJJIyGydtVjg3G"
        );
        
        // Insertar evaluación
        String sql = "INSERT INTO evaluaciones (proyecto_id, evaluador_id, calificacion, observaciones) VALUES (?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, proyectoId);
        pstmt.setString(2, usuarioId);
        pstmt.setString(3, calificacion);
        pstmt.setString(4, observaciones);
        pstmt.executeUpdate();
        
        // Actualizar estado del proyecto a finalizado
        String sqlUpdate = "UPDATE proyectos SET estado = 'finalizado', fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = ?";
        PreparedStatement pstmtUpdate = conn.prepareStatement(sqlUpdate);
        pstmtUpdate.setString(1, proyectoId);
        pstmtUpdate.executeUpdate();
        
        response.sendRedirect("dashboard.jsp?success=proyecto_evaluado");
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
    <title>Evaluar Proyecto - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <div class="form-container">
            <h2 style="text-align: center; color: var(--uts-red); margin-bottom: 30px;">⭐ Evaluar Proyecto</h2>
            
            <% if (proyectosEvaluacion.isEmpty()) { %>
                <div class="alert alert-success">
                    <strong>✅ No hay proyectos pendientes de evaluaci&#243;n</strong><br>
                    Todos los proyectos asignados han sido evaluados.
                </div>
                <div style="text-align: center; margin-top: 20px;">
                    <a href="dashboard.jsp" class="btn btn-uts">🏠 Volver al Dashboard</a>
                </div>
            <% } else { %>
                <form method="POST" action="evaluarProyecto.jsp">
                    <div class="form-group">
                        <label for="proyecto_id">Seleccionar Proyecto a Evaluar:</label>
                        <select class="form-control" id="proyecto_id" name="proyecto_id" required 
                                onchange="cargarDetallesProyecto(this.value)">
                            <option value="">-- Selecciona un proyecto --</option>
                            <% for (String[] proyecto : proyectosEvaluacion) { %>
                                <option value="<%= proyecto[0] %>" data-descripcion="<%= proyecto[4] %>">
                                    "<%= proyecto[1] %>" - Estudiante: <%= proyecto[2] %> (Director: <%= proyecto[3] %>)
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div id="detalles-proyecto" style="display: none; background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;">
                        <h4 style="color: var(--uts-red);">📋 Descripci&#243;n del Proyecto</h4>
                        <div id="info-descripcion" style="line-height: 1.6;"></div>
                        <div style="margin-top: 15px;">
                            <a href="#" id="link-anteproyecto" class="btn btn-info" style="padding: 5px 10px; font-size: 0.8em;" target="_blank">
                                📄 Ver Anteproyecto
                            </a>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="calificacion">Calificaci&#243;n (0.0 - 5.0):</label>
                        <input type="number" class="form-control" id="calificacion" name="calificacion" 
                               min="0" max="5" step="0.1" required placeholder="Ej: 4.5">
                    </div>
                    
                    <div class="form-group">
                        <label for="observaciones">Observaciones y Comentarios de Evaluaci&#243;n:</label>
                        <textarea class="form-control" id="observaciones" name="observaciones" rows="8" 
                                  placeholder="Proporciona una evaluaci&#243;n detallada del proyecto...&#10;&#10;Aspectos a considerar:&#10;- Calidad t&#233;cnica&#10;- Originalidad&#10;- Metodolog&#237;a&#10;- Resultados&#10;- Presentaci&#243;n"></textarea>
                    </div>
                    
                    <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0;">
                        <h4 style="color: var(--uts-red); margin-bottom: 10px;">📊 Criterios de Evaluaci&#243;n:</h4>
                        <ul style="text-align: left; color: #666;">
                            <li><strong>5.0:</strong> Excelente - Cumple todos los criterios de manera excepcional</li>
                            <li><strong>4.0-4.9:</strong> Muy Bueno - Cumple la mayor&#237;a de criterios satisfactoriamente</li>
                            <li><strong>3.0-3.9:</strong> Bueno - Cumple los criterios b&#225;sicos</li>
                            <li><strong>2.0-2.9:</strong> Regular - Requiere mejoras significativas</li>
                            <li><strong>0.0-1.9:</strong> Insuficiente - No cumple los criterios m&#237;nimos</li>
                        </ul>
                    </div>
                    
                    <div style="text-align: center; margin-top: 30px;">
                        <button type="submit" class="btn btn-success">📝 Enviar Evaluaci&#243;n</button>
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
        
        var select = document.getElementById('proyecto_id');
        var selectedOption = select.options[select.selectedIndex];
        var descripcion = selectedOption.getAttribute('data-descripcion');
        
        document.getElementById('detalles-proyecto').style.display = 'block';
        document.getElementById('info-descripcion').innerHTML = descripcion || 'No hay descripción disponible';
        
        // Simular link al anteproyecto (en un sistema real obtendrías la URL de la BD)
        document.getElementById('link-anteproyecto').href = 'https://drive.google.com/file/d/ejemplo/view';
    }
    </script>

    <%@ include file="../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>