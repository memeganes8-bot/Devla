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
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Proyectos para Evaluar - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <div class="welcome-section">
            <h1>📋 Proyectos para Evaluar</h1>
            <p>Lista de proyectos asignados para evaluaci&#243;n</p>
        </div>

        <div style="text-align: right; margin-bottom: 20px;">
            <a href="evaluarProyecto.jsp" class="btn btn-success">⭐ Evaluar Proyectos</a>
            <a href="dashboard.jsp" class="btn btn-uts">🏠 Volver al Dashboard</a>
        </div>

        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Estudiante</th>
                        <th>T&#237;tulo del Proyecto</th>
                        <th>Director</th>
                        <th>Estado</th>
                        <th>Fecha de Asignaci&#243;n</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection conn = DriverManager.getConnection(
                            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
                            "unsp1ogkp7qbzhgm", 
                            "ZXCRqDEJJIyGydtVjg3G"
                        );
                        
                        String sql = "SELECT p.id, p.titulo, e.nombre as estudiante, d.nombre as director, p.estado, p.fecha_actualizacion " +
                                    "FROM proyectos p " +
                                    "JOIN usuarios e ON p.estudiante_id = e.id " +
                                    "JOIN usuarios d ON p.director_id = d.id " +
                                    "WHERE p.evaluador_id = ? " +
                                    "ORDER BY p.fecha_actualizacion DESC";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, usuarioId);
                        ResultSet rs = pstmt.executeQuery();
                        
                        while (rs.next()) {
                            String estado = rs.getString("estado");
                            String estadoClass = "estado-" + estado;
                    %>
                    <tr>
                        <td><strong><%= rs.getString("estudiante") %></strong></td>
                        <td><%= rs.getString("titulo") %></td>
                        <td><%= rs.getString("director") %></td>
                        <td><span class="<%= estadoClass %>"><%= estado.toUpperCase() %></span></td>
                        <td><%= rs.getString("fecha_actualizacion") %></td>
                        <td>
                            <% if ("evaluacion".equals(estado)) { %>
                                <a href="evaluarProyecto.jsp?proyecto_id=<%= rs.getInt("id") %>" class="btn btn-success" style="padding: 5px 10px; font-size: 0.8em;">Evaluar</a>
                            <% } else if ("finalizado".equals(estado)) { %>
                                <span class="btn" style="padding: 5px 10px; font-size: 0.8em; background: var(--uts-green); color: white;">✅ Evaluado</span>
                            <% } else { %>
                                <span class="btn" style="padding: 5px 10px; font-size: 0.8em; background: var(--uts-gray); color: white;">⏳ Pendiente</span>
                            <% } %>
                        </td>
                    </tr>
                    <%
                        }
                        if (!rs.isBeforeFirst()) {
                            out.println("<tr><td colspan='6' style='text-align: center; padding: 40px;'>No tienes proyectos asignados para evaluaci&#243;n.</td></tr>");
                        }
                        conn.close();
                    } catch (Exception e) {
                        out.println("<tr><td colspan='6'>Error al cargar proyectos: " + e.getMessage() + "</td></tr>");
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <%@ include file="../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>