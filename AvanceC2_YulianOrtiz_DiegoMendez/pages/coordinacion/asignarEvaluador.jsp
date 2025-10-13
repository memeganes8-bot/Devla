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

if (!"coordinacion".equals(usuarioRol)) {
    response.sendRedirect("../../dashboard.jsp?error=acceso_denegado");
    return;
}

// Obtener proyectos aprobados sin evaluador
java.util.ArrayList<String[]> proyectosSinEvaluador = new java.util.ArrayList<>();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
        "unsp1ogkp7qbzhgm", 
        "ZXCRqDEJJIyGydtVjg3G"
    );
    
    String sql = "SELECT p.id, p.titulo, u.nombre as estudiante, d.nombre as director " +
                "FROM proyectos p " +
                "JOIN usuarios u ON p.estudiante_id = u.id " +
                "JOIN usuarios d ON p.director_id = d.id " +
                "WHERE p.estado = 'aprobado' AND p.evaluador_id IS NULL";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    ResultSet rs = pstmt.executeQuery();
    
    while (rs.next()) {
        String[] proyecto = {
            rs.getString("id"),
            rs.getString("titulo"),
            rs.getString("estudiante"),
            rs.getString("director")
        };
        proyectosSinEvaluador.add(proyecto);
    }
    conn.close();
} catch (Exception e) {
    out.println("<!-- Error: " + e.getMessage() + " -->");
}

// Obtener evaluadores disponibles (excluyendo al director del proyecto)
java.util.ArrayList<String[]> evaluadores = new java.util.ArrayList<>();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
        "unsp1ogkp7qbzhgm", 
        "ZXCRqDEJJIyGydtVjg3G"
    );
    
    String sql = "SELECT id, nombre, area_conocimiento FROM usuarios WHERE rol = 'evaluador' AND estado = 'activo'";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    ResultSet rs = pstmt.executeQuery();
    
    while (rs.next()) {
        String[] evaluador = {
            rs.getString("id"),
            rs.getString("nombre"),
            rs.getString("area_conocimiento")
        };
        evaluadores.add(evaluador);
    }
    conn.close();
} catch (Exception e) {
    out.println("<!-- Error: " + e.getMessage() + " -->");
}

// Procesar asignación de evaluador
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String proyectoId = request.getParameter("proyecto_id");
    String evaluadorId = request.getParameter("evaluador_id");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
            "unsp1ogkp7qbzhgm", 
            "ZXCRqDEJJIyGydtVjg3G"
        );
        
        // Verificar que el evaluador no sea el director del proyecto
        String sqlCheck = "SELECT director_id FROM proyectos WHERE id = ?";
        PreparedStatement pstmtCheck = conn.prepareStatement(sqlCheck);
        pstmtCheck.setString(1, proyectoId);
        ResultSet rsCheck = pstmtCheck.executeQuery();
        
        if (rsCheck.next()) {
            String directorId = rsCheck.getString("director_id");
            if (evaluadorId.equals(directorId)) {
                out.println("<div class='alert alert-error'>❌ Error: El evaluador no puede ser el mismo director del proyecto</div>");
            } else {
                // Asignar evaluador
                String sql = "UPDATE proyectos SET evaluador_id = ?, estado = 'evaluacion', fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = ?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, evaluadorId);
                pstmt.setString(2, proyectoId);
                
                int result = pstmt.executeUpdate();
                
                if (result > 0) {
                    response.sendRedirect("dashboard.jsp?success=evaluador_asignado");
                    return;
                }
            }
        }
        
        conn.close();
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
    <title>Asignar Evaluador - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <div class="form-container">
            <h2 style="text-align: center; color: var(--uts-red); margin-bottom: 30px;">⭐ Asignar Evaluador</h2>
            
            <% if (proyectosSinEvaluador.isEmpty()) { %>
                <div class="alert alert-success">
                    <strong>✅ Todos los proyectos aprobados tienen evaluador asignado</strong><br>
                    No hay proyectos pendientes de asignación de evaluador.
                </div>
                <div style="text-align: center; margin-top: 20px;">
                    <a href="dashboard.jsp" class="btn btn-uts">🏠 Volver al Dashboard</a>
                </div>
            <% } else if (evaluadores.isEmpty()) { %>
                <div class="alert alert-warning">
                    <strong>⚠️ No hay evaluadores disponibles</strong><br>
                    Es necesario registrar evaluadores en el sistema primero.
                </div>
                <div style="text-align: center; margin-top: 20px;">
                    <a href="../admin/registrarUsuario.jsp" class="btn btn-success">➕ Registrar Evaluador</a>
                    <a href="dashboard.jsp" class="btn btn-uts">🏠 Volver al Dashboard</a>
                </div>
            <% } else { %>
                <form method="POST" action="asignarEvaluador.jsp">
                    <div class="form-group">
                        <label for="proyecto_id">Seleccionar Proyecto Aprobado:</label>
                        <select class="form-control" id="proyecto_id" name="proyecto_id" required>
                            <option value="">-- Selecciona un proyecto --</option>
                            <% for (String[] proyecto : proyectosSinEvaluador) { %>
                                <option value="<%= proyecto[0] %>">
                                    "<%= proyecto[1] %>" - Estudiante: <%= proyecto[2] %> (Director: <%= proyecto[3] %>)
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="evaluador_id">Seleccionar Evaluador:</label>
                        <select class="form-control" id="evaluador_id" name="evaluador_id" required>
                            <option value="">-- Selecciona un evaluador --</option>
                            <% for (String[] evaluador : evaluadores) { %>
                                <option value="<%= evaluador[0] %>">
                                    <%= evaluador[1] %> - Área: <%= evaluador[2] %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0;">
                        <h4 style="color: var(--uts-red); margin-bottom: 10px;">📝 Reglas de Asignación:</h4>
                        <ul style="text-align: left; color: #666;">
                            <li>El evaluador <strong>NO puede ser el mismo director</strong> del proyecto</li>
                            <li>El proyecto debe estar en estado "Aprobado" por el director</li>
                            <li>El evaluador realizará la evaluación final del trabajo de grado</li>
                            <li>Una vez asignado, el proyecto cambiará a estado "Evaluación"</li>
                        </ul>
                    </div>
                    
                    <div style="text-align: center; margin-top: 30px;">
                        <button type="submit" class="btn btn-success">✅ Asignar Evaluador</button>
                        <a href="dashboard.jsp" class="btn btn-uts">↩️ Cancelar</a>
                    </div>
                </form>
            <% } %>
        </div>
    </div>

    <%@ include file="../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>