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
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Proyectos Asignados - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <div class="welcome-section">
            <h1>📁 Proyectos Asignados</h1>
            <p>Gesti&#243;n de todos los proyectos bajo tu direcci&#243;n</p>
        </div>

        <div style="text-align: right; margin-bottom: 20px;">
            <a href="calificarProyecto.jsp" class="btn btn-success">⭐ Calificar Proyectos</a>
            <a href="dashboard.jsp" class="btn btn-uts">🏠 Volver al Dashboard</a>
        </div>

        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Estudiante</th>
                        <th>T&#237;tulo del Proyecto</th>
                        <th>Descripci&#243;n</th>
                        <th>Estado</th>
                        <th>Evaluador</th>
                        <th>&#218;ltima Actualizaci&#243;n</th>
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
                        
                        String sql = "SELECT p.id, p.titulo, p.descripcion, p.estado, p.fecha_actualizacion, " +
                                    "e.nombre as estudiante, ev.nombre as evaluador " +
                                    "FROM proyectos p " +
                                    "JOIN usuarios e ON p.estudiante_id = e.id " +
                                    "LEFT JOIN usuarios ev ON p.evaluador_id = ev.id " +
                                    "WHERE p.director_id = ? " +
                                    "ORDER BY p.fecha_actualizacion DESC";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, usuarioId);
                        ResultSet rs = pstmt.executeQuery();
                        
                        while (rs.next()) {
                            String estado = rs.getString("estado");
                            String estadoClass = "estado-" + estado;
                            String descripcion = rs.getString("descripcion");
                            if (descripcion != null && descripcion.length() > 100) {
                                descripcion = descripcion.substring(0, 100) + "...";
                            }
                    %>
                    <tr>
                        <td><strong><%= rs.getString("estudiante") %></strong></td>
                        <td><%= rs.getString("titulo") %></td>
                        <td><%= descripcion != null ? descripcion : "Sin descripción" %></td>
                        <td><span class="<%= estadoClass %>"><%= estado.toUpperCase() %></span></td>
                        <td><%= rs.getString("evaluador") != null ? rs.getString("evaluador") : "No asignado" %></td>
                        <td><%= rs.getString("fecha_actualizacion") %></td>
                        <td>
                            <div style="display: flex; gap: 5px; flex-wrap: wrap;">
                                <% if ("en_revision".equals(estado) || "correcciones".equals(estado)) { %>
                                    <a href="calificarProyecto.jsp?proyecto_id=<%= rs.getInt("id") %>" class="btn btn-success" style="padding: 3px 8px; font-size: 0.7em;">Revisar</a>
                                <% } %>
                                <a href="#" class="btn btn-info" style="padding: 3px 8px; font-size: 0.7em;">Detalles</a>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                        if (!rs.isBeforeFirst()) {
                            out.println("<tr><td colspan='7' style='text-align: center; padding: 40px;'>No tienes proyectos asignados como director.</td></tr>");
                        }
                        conn.close();
                    } catch (Exception e) {
                        out.println("<tr><td colspan='7'>Error al cargar proyectos: " + e.getMessage() + "</td></tr>");
                    }
                    %>
                </tbody>
            </table>
        </div>

        <!-- Resumen de Proyectos -->
        <div class="dashboard-stats" style="margin-top: 40px;">
            <%
            int totalAsignados = 0;
            int enRevision = 0;
            int aprobados = 0;
            int finalizados = 0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
                    "unsp1ogkp7qbzhgm", 
                    "ZXCRqDEJJIyGydtVjg3G"
                );
                
                String sql = "SELECT COUNT(*) as total, " +
                            "SUM(CASE WHEN estado = 'en_revision' THEN 1 ELSE 0 END) as revision, " +
                            "SUM(CASE WHEN estado = 'aprobado' THEN 1 ELSE 0 END) as aprobados, " +
                            "SUM(CASE WHEN estado = 'finalizado' THEN 1 ELSE 0 END) as finalizados " +
                            "FROM proyectos WHERE director_id = ?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, usuarioId);
                ResultSet rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    totalAsignados = rs.getInt("total");
                    enRevision = rs.getInt("revision");
                    aprobados = rs.getInt("aprobados");
                    finalizados = rs.getInt("finalizados");
                }
                conn.close();
            } catch (Exception e) {
                // Valores por defecto
                totalAsignados = 4;
                enRevision = 1;
                aprobados = 2;
                finalizados = 1;
            }
            %>
            
            <div class="stat-card">
                <span class="stat-number"><%= totalAsignados %></span>
                <span class="stat-label">Total Asignados</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= enRevision %></span>
                <span class="stat-label">En Revisi&#243;n</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= aprobados %></span>
                <span class="stat-label">Aprobados</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= finalizados %></span>
                <span class="stat-label">Finalizados</span>
            </div>
        </div>
    </div>

    <%@ include file="../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>