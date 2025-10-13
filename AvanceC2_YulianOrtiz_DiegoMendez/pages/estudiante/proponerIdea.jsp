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

// Procesar propuesta de idea
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String titulo = request.getParameter("titulo");
    String descripcion = request.getParameter("descripcion");
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
            "unsp1ogkp7qbzhgm", 
            "ZXCRqDEJJIyGydtVjg3G"
        );
        
        String sql = "INSERT INTO proyectos (titulo, descripcion, estudiante_id, estado) VALUES (?, ?, ?, 'pendiente')";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, titulo);
        pstmt.setString(2, descripcion);
        pstmt.setString(3, usuarioId);
        
        int result = pstmt.executeUpdate();
        
        if (result > 0) {
            response.sendRedirect("dashboard.jsp?success=idea_propuesta");
            return;
        }
        
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>❌ Error: " + e.getMessage() + "</div>");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Proponer Idea - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <div class="form-container">
            <h2 style="text-align: center; color: var(--uts-red); margin-bottom: 30px;">💡 Proponer Nueva Idea</h2>
            
            <form method="POST" action="proponerIdea.jsp">
                <div class="form-group">
                    <label for="titulo">T&#237;tulo del Proyecto:</label>
                    <input type="text" class="form-control" id="titulo" name="titulo" required 
                           placeholder="Ej: Sistema de Gesti&#243;n Acad&#233;mica para la UTS">
                </div>
                
                <div class="form-group">
                    <label for="descripcion">Descripci&#243;n Detallada:</label>
                    <textarea class="form-control" id="descripcion" name="descripcion" rows="6" required 
                              placeholder="Describe detalladamente tu propuesta de proyecto..."></textarea>
                </div>
                
                <div style="text-align: center; margin-top: 30px;">
                    <button type="submit" class="btn btn-success">🚀 Proponer Idea</button>
                    <a href="dashboard.jsp" class="btn btn-uts">↩️ Cancelar</a>
                </div>
            </form>
        </div>
    </div>

    <%@ include file="../../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>