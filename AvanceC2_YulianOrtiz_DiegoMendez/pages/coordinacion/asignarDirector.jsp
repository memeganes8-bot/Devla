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

// Obtener proyectos sin director
java.util.ArrayList<String[]> proyectosSinDirector = new java.util.ArrayList<>();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
        "unsp1ogkp7qbzhgm", 
        "ZXCRqDEJJIyGydtVjg3G"
    );
    
    String sql = "SELECT p.id, p.titulo, u.nombre as estudiante, u.email " +
                "FROM proyectos p JOIN usuarios u ON p.estudiante_id = u.id " +
                "WHERE p.director_id IS NULL";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    ResultSet rs = pstmt.executeQuery();
    
    while (rs.next()) {
        String[] proyecto = {
            rs.getString("id"),
            rs.getString("titulo"),
            rs.getString("estudiante"),
            rs.getString("email")
        };
        proyectosSinDirector.add(proyecto);
    }
    conn.close();
} catch (Exception e) {
    out.println("<!-- Error: " + e.getMessage() + " -->");
}

// Obtener directores disponibles
java.util.ArrayList<String[]> directores = new java.util.ArrayList<>();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
        "unsp1ogkp7qbzhgm", 
        "ZXCRqDEJJIyGydtVjg3G"
    );
    
    String sql = "SELECT id, nombre, area_conocimiento FROM usuarios WHERE rol = 'director' AND estado = 'activo'";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    ResultSet rs = pstmt.executeQuery();
    
    while (rs.next()) {
        String[] director = {
            rs.getString("id"),
            rs.getString("nombre"),
            rs.getString("area_conocimiento")
        };
        directores.add(director);
    }
    conn.close();
} catch (Exception e) {
    out.println("<!-- Error: " + e.getMessage() + " -->");
}

// Procesar asignación de director
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String proyectoId = request.getParameter("proyecto_id");
    String directorId = request.getParameter("director_id");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
            "unsp1ogkp7qbzhgm", 
            "ZXCRqDEJJIyGydtVjg3G"
        );
        
        String sql = "UPDATE proyectos SET director_id = ?, fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, directorId);
        pstmt.setString(2, proyectoId);
        
        int result = pstmt.executeUpdate();
        
        if (result > 0) {
            response.sendRedirect("dashboard.jsp?success=director_asignado");
            return;
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
    <title>Asignar Director - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <div class="form-container">
            <h2 style="text-align: center; color: var(--uts-red); margin-bottom: 30px;">👨‍🏫 Asignar Director</h2>
            
            <% if (proyectosSinDirector.isEmpty()) { %>
                <div class="alert alert-success">
                    <strong>✅ Todos los proyectos tienen director asignado</strong><br>
                    No hay proyectos pendientes de asignación de director.
                </div>
                <div style="text-align: center; margin-top: 20px;">
                    <a href="dashboard.jsp" class="btn btn-uts">🏠 Volver al Dashboard</a>
                </div>
            <% } else if (directores.isEmpty()) { %>
                <div class="alert alert-warning">
                    <strong>⚠️ No hay directores disponibles</strong><br>
                    Es necesario registrar directores en el sistema primero.
                </div>
                <div style="text-align: center; margin-top: 20px;">
                    <a href="../admin/registrarUsuario.jsp" class="btn btn-success">➕ Registrar Director</a>
                    <a href="dashboard.jsp" class="btn btn-uts">🏠 Volver al Dashboard</a>
                </div>
            <% } else { %>
                <form method="POST" action="asignarDirector.jsp">
                    <div class="form-group">
                        <label for="proyecto_id">Seleccionar Proyecto:</label>
                        <select class="form-control" id="proyecto_id" name="proyecto_id" required>
                            <option value="">-- Selecciona un proyecto --</option>
                            <% for (String[] proyecto : proyectosSinDirector) { %>
                                <option value="<%= proyecto[0] %>">
                                    "<%= proyecto[1] %>" - Estudiante: <%= proyecto[2] %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="director_id">Seleccionar Director:</label>
                        <select class="form-control" id="director_id" name="director_id" required>
                            <option value="">-- Selecciona un director --</option>
                            <% for (String[] director : directores) { %>
                                <option value="<%= director[0] %>">
                                    <%= director[1] %> - Área: <%= director[2] %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0;">
                        <h4 style="color: var(--uts-red); margin-bottom: 10px;">📝 Información:</h4>
                        <ul style="text-align: left; color: #666;">
                            <li>Al asignar un director, el estudiante será notificado</li>
                            <li>El director podrá revisar y calificar el anteproyecto</li>
                            <li>Una vez asignado, el proyecto cambiará a estado "En revisión"</li>
                        </ul>
                    </div>
                    
                    <div style="text-align: center; margin-top: 30px;">
                        <button type="submit" class="btn btn-success">✅ Asignar Director</button>
                        <a href="dashboard.jsp" class="btn btn-uts">↩️ Cancelar</a>
                    </div>
                </form>
            <% } %>
        </div>
    </div>

    <%@ include file="../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>