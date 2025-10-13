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

if (!"estudiante".equals(usuarioRol)) {
    response.sendRedirect("../../dashboard.jsp?error=acceso_denegado");
    return;
}

// Obtener proyectos del estudiante
java.util.ArrayList<String[]> proyectos = new java.util.ArrayList<>();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
        "unsp1ogkp7qbzhgm", 
        "ZXCRqDEJJIyGydtVjg3G"
    );
    
    String sql = "SELECT id, titulo, estado FROM proyectos WHERE estudiante_id = ?";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, usuarioId);
    ResultSet rs = pstmt.executeQuery();
    
    while (rs.next()) {
        String[] proyecto = {
            rs.getString("id"),
            rs.getString("titulo"),
            rs.getString("estado")
        };
        proyectos.add(proyecto);
    }
    conn.close();
} catch (Exception e) {
    out.println("<!-- Error: " + e.getMessage() + " -->");
}

// Procesar subida de anteproyecto
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String proyectoId = request.getParameter("proyecto_id");
    String urlAnteproyecto = request.getParameter("url_anteproyecto");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
            "unsp1ogkp7qbzhgm", 
            "ZXCRqDEJJIyGydtVjg3G"
        );
        
        // Obtener la última versión
        String sqlVersion = "SELECT COALESCE(MAX(version), 0) as ultima_version FROM versiones_anteproyecto WHERE proyecto_id = ?";
        PreparedStatement pstmtVersion = conn.prepareStatement(sqlVersion);
        pstmtVersion.setString(1, proyectoId);
        ResultSet rsVersion = pstmtVersion.executeQuery();
        
        int nuevaVersion = 1;
        if (rsVersion.next()) {
            nuevaVersion = rsVersion.getInt("ultima_version") + 1;
        }
        
        // Insertar nueva versión
        String sql = "INSERT INTO versiones_anteproyecto (proyecto_id, version, url_anteproyecto, estado) VALUES (?, ?, ?, 'pendiente')";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, proyectoId);
        pstmt.setInt(2, nuevaVersion);
        pstmt.setString(3, urlAnteproyecto);
        
        int result = pstmt.executeUpdate();
        
        // Actualizar estado del proyecto
        String sqlUpdate = "UPDATE proyectos SET estado = 'en_revision', fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = ?";
        PreparedStatement pstmtUpdate = conn.prepareStatement(sqlUpdate);
        pstmtUpdate.setString(1, proyectoId);
        pstmtUpdate.executeUpdate();
        
        if (result > 0) {
            response.sendRedirect("dashboard.jsp?success=anteproyecto_subido");
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
    <title>Subir Anteproyecto - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <div class="form-container">
            <h2 style="text-align: center; color: var(--uts-red); margin-bottom: 30px;">📤 Subir Anteproyecto</h2>
            
            <% if (proyectos.isEmpty()) { %>
                <div class="alert alert-warning">
                    <strong>⚠️ No tienes proyectos registrados</strong><br>
                    Primero debes proponer una idea de proyecto antes de subir un anteproyecto.
                </div>
                <div style="text-align: center; margin-top: 20px;">
                    <a href="proponerIdea.jsp" class="btn btn-success">💡 Proponer Idea</a>
                    <a href="dashboard.jsp" class="btn btn-uts">🏠 Volver al Dashboard</a>
                </div>
            <% } else { %>
                <form method="POST" action="subirAnteproyecto.jsp">
                    <div class="form-group">
                        <label for="proyecto_id">Seleccionar Proyecto:</label>
                        <select class="form-control" id="proyecto_id" name="proyecto_id" required>
                            <option value="">-- Selecciona un proyecto --</option>
                            <% for (String[] proyecto : proyectos) { %>
                                <option value="<%= proyecto[0] %>">
                                    <%= proyecto[1] %> - Estado: <%= proyecto[2] %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="url_anteproyecto">URL del Anteproyecto (Google Drive/Dropbox):</label>
                        <input type="url" class="form-control" id="url_anteproyecto" name="url_anteproyecto" required 
                               placeholder="https://drive.google.com/file/d/...">
                        <small style="color: #666;">Sube tu archivo a Google Drive, Dropbox o similar y pega el link aquí</small>
                    </div>
                    
                    <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0;">
                        <h4 style="color: var(--uts-red); margin-bottom: 10px;">📝 Instrucciones:</h4>
                        <ul style="text-align: left; color: #666;">
                            <li>Sube tu anteproyecto en formato PDF a Google Drive o Dropbox</li>
                            <li>Asegúrate de que el enlace sea público o accesible</li>
                            <li>El documento debe incluir: Portada, Resumen, Introducción, Objetivos, Metodología</li>
                            <li>Una vez subido, el director asignado revisará tu anteproyecto</li>
                        </ul>
                    </div>
                    
                    <div style="text-align: center; margin-top: 30px;">
                        <button type="submit" class="btn btn-success">📤 Subir Anteproyecto</button>
                        <a href="dashboard.jsp" class="btn btn-uts">↩️ Cancelar</a>
                    </div>
                </form>
            <% } %>
        </div>
    </div>

    <%@ include file="../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>