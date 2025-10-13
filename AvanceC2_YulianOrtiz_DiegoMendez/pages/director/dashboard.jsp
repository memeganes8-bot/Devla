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

String usuarioNombre = (String) session.getAttribute("usuario_nombre");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Director - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <header class="uts-header">
        <div class="header-container">
            <div class="logo-section">
                <img src="../../img/logo-uts.png" alt="Logo UTS" class="uts-logo">
                <div>
                    <h1 class="uts-title">Unidades Tecnol&#243;gicas de Santander</h1>
                    <p class="uts-subtitle">Panel del Director</p>
                </div>
            </div>
            <div class="user-info">
                <span class="user-welcome">Bienvenido, <%= usuarioNombre %></span>
                <span class="user-role">DIRECTOR</span>
                <a href="../../logout.jsp" class="logout-btn">Cerrar Sesi&#243;n</a>
            </div>
        </div>
        
        <nav class="main-nav">
            <ul>
                <li><a href="dashboard.jsp">Dashboard</a></li>
                <li><a href="proyectosAsignados.jsp">Proyectos Asignados</a></li>
                <li><a href="calificarProyecto.jsp">Calificar Proyectos</a></li>
                <li><a href="https://www.uts.edu.co/sitio/calendario-academico" target="_blank">Calendario Acad&#233;mico</a></li>
                <li><a href="http://repositorio.uts.edu.co:8080/xmlui/handle/123456789/3949" target="_blank">Formatos de Grado</a></li>
            </ul>
        </nav>
    </header>

    <div class="main-content">
        <div class="welcome-section">
            <h1>👨‍🏫 Panel del Director</h1>
            <p>Gestiona y califica los proyectos de grado asignados</p>
        </div>

        <!-- Estadísticas del Director -->
        <div class="dashboard-stats">
            <%
            int proyectosAsignados = 0;
            int proyectosPendientes = 0;
            int proyectosAprobados = 0;
            int proyectosCorrecciones = 0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
                    "unsp1ogkp7qbzhgm", 
                    "ZXCRqDEJJIyGydtVjg3G"
                );
                
                // Proyectos asignados
                String sql1 = "SELECT COUNT(*) as total FROM proyectos WHERE director_id = ?";
                PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                pstmt1.setString(1, usuarioId);
                ResultSet rs1 = pstmt1.executeQuery();
                if (rs1.next()) proyectosAsignados = rs1.getInt("total");
                
                // Proyectos pendientes
                String sql2 = "SELECT COUNT(*) as total FROM proyectos WHERE director_id = ? AND estado = 'en_revision'";
                PreparedStatement pstmt2 = conn.prepareStatement(sql2);
                pstmt2.setString(1, usuarioId);
                ResultSet rs2 = pstmt2.executeQuery();
                if (rs2.next()) proyectosPendientes = rs2.getInt("total");
                
                // Proyectos aprobados
                String sql3 = "SELECT COUNT(*) as total FROM proyectos WHERE director_id = ? AND estado = 'aprobado'";
                PreparedStatement pstmt3 = conn.prepareStatement(sql3);
                pstmt3.setString(1, usuarioId);
                ResultSet rs3 = pstmt3.executeQuery();
                if (rs3.next()) proyectosAprobados = rs3.getInt("total");
                
                // Proyectos con correcciones
                String sql4 = "SELECT COUNT(*) as total FROM proyectos WHERE director_id = ? AND estado = 'correcciones'";
                PreparedStatement pstmt4 = conn.prepareStatement(sql4);
                pstmt4.setString(1, usuarioId);
                ResultSet rs4 = pstmt4.executeQuery();
                if (rs4.next()) proyectosCorrecciones = rs4.getInt("total");
                
                conn.close();
            } catch (Exception e) {
                out.println("<!-- Error: " + e.getMessage() + " -->");
            }
            %>
            
            <div class="stat-card">
                <span class="stat-number"><%= proyectosAsignados %></span>
                <span class="stat-label">Proyectos Asignados</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= proyectosPendientes %></span>
                <span class="stat-label">Pendientes de Revisi&#243;n</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= proyectosAprobados %></span>
                <span class="stat-label">Proyectos Aprobados</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= proyectosCorrecciones %></span>
                <span class="stat-label">Con Correcciones</span>
            </div>
        </div>

        <!-- Acciones del Director -->
        <div class="role-cards">
            <div class="role-card">
                <h3>📋 Proyectos Asignados</h3>
                <p>Consulta todos los proyectos que tienes asignados como director</p>
                <a href="proyectosAsignados.jsp" class="btn btn-uts">Ver Proyectos</a>
            </div>
            
            <div class="role-card">
                <h3>⭐ Calificar Proyectos</h3>
                <p>Revisa y califica los anteproyectos de tus estudiantes</p>
                <a href="calificarProyecto.jsp" class="btn btn-success">Calificar Proyectos</a>
            </div>
            
            <div class="role-card">
                <h3>📊 Historial de Evaluaciones</h3>
                <p>Revisa el historial de tus evaluaciones y comentarios</p>
                <a href="#" class="btn btn-info">Ver Historial</a>
            </div>
        </div>

        <!-- Proyectos Pendientes de Revisión -->
        <div style="margin-top: 40px;">
            <h3 style="color: var(--uts-red); margin-bottom: 20px;">⏰ Proyectos Pendientes de Revisi&#243;n</h3>
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Estudiante</th>
                            <th>T&#237;tulo del Proyecto</th>
                            <th>Fecha de Entrega</th>
                            <th>Versi&#243;n</th>
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
                            
                            String sql = "SELECT p.id, p.titulo, u.nombre as estudiante, v.fecha_subida, v.version " +
                                        "FROM proyectos p " +
                                        "JOIN usuarios u ON p.estudiante_id = u.id " +
                                        "JOIN versiones_anteproyecto v ON p.id = v.proyecto_id " +
                                        "WHERE p.director_id = ? AND v.estado = 'pendiente' " +
                                        "ORDER BY v.fecha_subida DESC LIMIT 5";
                            PreparedStatement pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, usuarioId);
                            ResultSet rs = pstmt.executeQuery();
                            
                            while (rs.next()) {
                        %>
                        <tr>
                            <td><strong><%= rs.getString("estudiante") %></strong></td>
                            <td><%= rs.getString("titulo") %></td>
                            <td><%= rs.getString("fecha_subida") %></td>
                            <td>v<%= rs.getString("version") %></td>
                            <td>
                                <a href="calificarProyecto.jsp?proyecto_id=<%= rs.getInt("id") %>" class="btn btn-success" style="padding: 5px 10px; font-size: 0.8em;">Revisar</a>
                            </td>
                        </tr>
                        <%
                            }
                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='5'>No hay proyectos pendientes de revisi&#243;n</td></tr>");
                            }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5'>Error: " + e.getMessage() + "</td></tr>");
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <footer class="uts-footer">
        <div class="footer-container">
            <div class="footer-info">
                <h3>Unidades Tecnol&#243;gicas de Santander</h3>
                <p>Sistema de Gesti&#243;n de Trabajos de Grado</p>
                <p>&copy; 2024 Todos los derechos reservados</p>
            </div>
            <div class="footer-links">
                <a href="https://www.uts.edu.co/sitio/calendario-academico" target="_blank">📅 Calendario Acad&#233;mico</a>
                <a href="http://repositorio.uts.edu.co:8080/xmlui/handle/123456789/3949" target="_blank">📑 Formatos de Grado</a>
                <a href="mailto:sistemas@uts.edu.co">📧 Contacto</a>
            </div>
        </div>
    </footer>
</body>
</html>