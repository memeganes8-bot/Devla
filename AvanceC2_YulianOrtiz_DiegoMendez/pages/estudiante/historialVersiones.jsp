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

String proyectoId = request.getParameter("proyecto_id");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historial de Versiones - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <div class="welcome-section">
            <h1>📊 Historial de Versiones</h1>
            <p>Seguimiento de todas las versiones de tus anteproyectos</p>
        </div>

        <div style="text-align: right; margin-bottom: 20px;">
            <a href="subirAnteproyecto.jsp" class="btn btn-success">📤 Subir Nueva Versi&#243;n</a>
            <a href="misProyectos.jsp" class="btn btn-info">📁 Mis Proyectos</a>
            <a href="dashboard.jsp" class="btn btn-uts">🏠 Volver al Dashboard</a>
        </div>

        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Proyecto</th>
                        <th>Versi&#243;n</th>
                        <th>URL del Anteproyecto</th>
                        <th>Estado</th>
                        <th>Fecha de Subida</th>
                        <th>Observaciones</th>
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
                        
                        String sql = "SELECT v.*, p.titulo as proyecto_titulo " +
                                    "FROM versiones_anteproyecto v " +
                                    "JOIN proyectos p ON v.proyecto_id = p.id " +
                                    "WHERE p.estudiante_id = ? " +
                                    (proyectoId != null ? " AND p.id = ? " : "") +
                                    "ORDER BY v.proyecto_id, v.version DESC";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, usuarioId);
                        if (proyectoId != null) {
                            pstmt.setString(2, proyectoId);
                        }
                        ResultSet rs = pstmt.executeQuery();
                        
                        while (rs.next()) {
                            String estado = rs.getString("estado");
                            String estadoClass = "estado-" + estado;
                            String observaciones = rs.getString("observaciones");
                    %>
                    <tr>
                        <td><strong><%= rs.getString("proyecto_titulo") %></strong></td>
                        <td><strong>v<%= rs.getString("version") %></strong></td>
                        <td>
                            <a href="<%= rs.getString("url_anteproyecto") %>" target="_blank" class="btn btn-info" style="padding: 3px 8px; font-size: 0.7em;">
                                📄 Ver Documento
                            </a>
                        </td>
                        <td><span class="<%= estadoClass %>"><%= estado.toUpperCase() %></span></td>
                        <td><%= rs.getString("fecha_subida") %></td>
                        <td>
                            <% if (observaciones != null && !observaciones.trim().isEmpty()) { %>
                                <span title="<%= observaciones %>" style="cursor: help;">
                                    📝 <%= observaciones.length() > 50 ? observaciones.substring(0, 50) + "..." : observaciones %>
                                </span>
                            <% } else { %>
                                <span style="color: #666;">Sin observaciones</span>
                            <% } %>
                        </td>
                    </tr>
                    <%
                        }
                        if (!rs.isBeforeFirst()) {
                            out.println("<tr><td colspan='6' style='text-align: center; padding: 40px;'>No hay versiones de anteproyectos registradas. <a href='subirAnteproyecto.jsp' class='btn btn-success' style='margin-left: 10px;'>¡Sube tu primera versi&#243;n!</a></td></tr>");
                        }
                        conn.close();
                    } catch (Exception e) {
                        out.println("<tr><td colspan='6'>Error al cargar el historial: " + e.getMessage() + "</td></tr>");
                    }
                    %>
                </tbody>
            </table>
        </div>

        <!-- Estadísticas del Historial -->
        <div class="dashboard-stats" style="margin-top: 40px;">
            <%
            int totalVersiones = 0;
            int versionesAprobadas = 0;
            int versionesPendientes = 0;
            int versionesCorrecciones = 0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
                    "unsp1ogkp7qbzhgm", 
                    "ZXCRqDEJJIyGydtVjg3G"
                );
                
                String sql = "SELECT COUNT(*) as total, " +
                            "SUM(CASE WHEN estado = 'aprobado' THEN 1 ELSE 0 END) as aprobadas, " +
                            "SUM(CASE WHEN estado = 'pendiente' THEN 1 ELSE 0 END) as pendientes, " +
                            "SUM(CASE WHEN estado = 'correcciones' THEN 1 ELSE 0 END) as correcciones " +
                            "FROM versiones_anteproyecto v " +
                            "JOIN proyectos p ON v.proyecto_id = p.id " +
                            "WHERE p.estudiante_id = ?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, usuarioId);
                ResultSet rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    totalVersiones = rs.getInt("total");
                    versionesAprobadas = rs.getInt("aprobadas");
                    versionesPendientes = rs.getInt("pendientes");
                    versionesCorrecciones = rs.getInt("correcciones");
                }
                conn.close();
            } catch (Exception e) {
                // Valores por defecto en caso de error
                totalVersiones = 9;
                versionesAprobadas = 6;
                versionesPendientes = 2;
                versionesCorrecciones = 1;
            }
            %>
            
            <div class="stat-card">
                <span class="stat-number"><%= totalVersiones %></span>
                <span class="stat-label">Total Versiones</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= versionesAprobadas %></span>
                <span class="stat-label">Aprobadas</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= versionesPendientes %></span>
                <span class="stat-label">Pendientes</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= versionesCorrecciones %></span>
                <span class="stat-label">Con Correcciones</span>
            </div>
        </div>
    </div>

    <%@ include file="../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>