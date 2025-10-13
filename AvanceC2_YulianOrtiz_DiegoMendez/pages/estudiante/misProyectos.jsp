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
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Proyectos - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <div class="welcome-section">
            <h1>📁 Mis Proyectos</h1>
            <p>Gestiona y consulta el estado de todos tus proyectos de grado</p>
        </div>

        <div style="text-align: right; margin-bottom: 20px;">
            <a href="proponerIdea.jsp" class="btn btn-success">💡 Proponer Nueva Idea</a>
            <a href="dashboard.jsp" class="btn btn-uts">🏠 Volver al Dashboard</a>
        </div>

        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>T&#237;tulo</th>
                        <th>Descripci&#243;n</th>
                        <th>Estado</th>
                        <th>Director</th>
                        <th>Evaluador</th>
                        <th>Fecha de Creaci&#243;n</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection(
                            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
                            "unsp1ogkp7qbzhgm", 
                            "ZXCRqDEJJIyGydtVjg3G"
                        );
                        
                        // CONSULTA CORREGIDA - Usando los alias correctos
                        String sql = "SELECT p.*, " +
                                    "d.nombre as director_nombre, " +
                                    "ev.nombre as evaluador_nombre " +
                                    "FROM proyectos p " +
                                    "LEFT JOIN usuarios d ON p.director_id = d.id " +
                                    "LEFT JOIN usuarios ev ON p.evaluador_id = ev.id " +
                                    "WHERE p.estudiante_id = ? " +
                                    "ORDER BY p.fecha_creacion DESC";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, usuarioId);
                        rs = pstmt.executeQuery();
                        
                        while (rs.next()) {
                            String estado = rs.getString("estado");
                            String estadoClass = "estado-" + estado;
                            String descripcion = rs.getString("descripcion");
                            if (descripcion != null && descripcion.length() > 100) {
                                descripcion = descripcion.substring(0, 100) + "...";
                            }
                    %>
                    <tr>
                        <td><strong><%= rs.getString("titulo") %></strong></td>
                        <td><%= descripcion != null ? descripcion : "Sin descripción" %></td>
                        <td><span class="<%= estadoClass %>"><%= estado.toUpperCase() %></span></td>
                        <td><%= rs.getString("director_nombre") != null ? rs.getString("director_nombre") : "No asignado" %></td>
                        <td><%= rs.getString("evaluador_nombre") != null ? rs.getString("evaluador_nombre") : "No asignado" %></td>
                        <td><%= rs.getString("fecha_creacion") %></td>
                        <td>
                            <div style="display: flex; gap: 5px; flex-wrap: wrap;">
                                <a href="subirAnteproyecto.jsp?proyecto_id=<%= rs.getInt("id") %>" class="btn btn-info" style="padding: 3px 8px; font-size: 0.7em;">Subir</a>
                                <a href="historialVersiones.jsp?proyecto_id=<%= rs.getInt("id") %>" class="btn" style="padding: 3px 8px; font-size: 0.7em; background: var(--uts-blue);">Historial</a>
                                <% if ("finalizado".equals(estado)) { %>
                                    <a href="#" class="btn btn-success" style="padding: 3px 8px; font-size: 0.7em;">Ver Nota</a>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                        if (!rs.isBeforeFirst()) {
                            out.println("<tr><td colspan='7' style='text-align: center; padding: 40px;'>No tienes proyectos registrados. <a href='proponerIdea.jsp' class='btn btn-success' style='margin-left: 10px;'>¡Crea tu primer proyecto!</a></td></tr>");
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='7'>Error al cargar proyectos: " + e.getMessage() + "</td></tr>");
                    } finally {
                        try { if (rs != null) rs.close(); } catch (Exception e) {}
                        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
                        try { if (conn != null) conn.close(); } catch (Exception e) {}
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <%@ include file="../../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>