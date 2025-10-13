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

String usuarioNombre = (String) session.getAttribute("usuario_nombre");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Estudiante - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <header class="uts-header">
        <div class="header-container">
            <div class="logo-section">
                <img src="../../img/logo-uts.png" alt="Logo UTS" class="uts-logo">
                <div>
                    <h1 class="uts-title">Unidades Tecnol&#243;gicas de Santander</h1>
                    <p class="uts-subtitle">Panel del Estudiante</p>
                </div>
            </div>
            <div class="user-info">
                <span class="user-welcome">Bienvenido, <%= usuarioNombre %></span>
                <span class="user-role">ESTUDIANTE</span>
                <a href="../../logout.jsp" class="logout-btn">Cerrar Sesi&#243;n</a>
            </div>
        </div>
        
        <nav class="main-nav">
            <ul>
                <li><a href="dashboard.jsp">Dashboard</a></li>
                <li><a href="proponerIdea.jsp">Proponer Idea</a></li>
                <li><a href="misProyectos.jsp">Mis Proyectos</a></li>
                <li><a href="subirAnteproyecto.jsp">Subir Anteproyecto</a></li>
                <li><a href="https://www.uts.edu.co/sitio/calendario-academico" target="_blank">Calendario Acad&#233;mico</a></li>
                <li><a href="http://repositorio.uts.edu.co:8080/xmlui/handle/123456789/3949" target="_blank">Formatos de Grado</a></li>
            </ul>
        </nav>
    </header>

    <div class="main-content">
        <div class="welcome-section">
            <h1>🎓 Panel del Estudiante</h1>
            <p>Gestiona tu trabajo de grado desde el anteproyecto hasta la entrega final</p>
        </div>

        <!-- Progreso del Estudiante -->
        <div class="dashboard-stats">
            <%
            int proyectosActivos = 0;
            int entregasPendientes = 0;
            int proyectosAprobados = 0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
                    "unsp1ogkp7qbzhgm", 
                    "ZXCRqDEJJIyGydtVjg3G"
                );
                
                // Proyectos activos del estudiante
                String sql1 = "SELECT COUNT(*) as total FROM proyectos WHERE estudiante_id = ?";
                PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                pstmt1.setString(1, usuarioId);
                ResultSet rs1 = pstmt1.executeQuery();
                if (rs1.next()) proyectosActivos = rs1.getInt("total");
                
                // Proyectos aprobados
                String sql2 = "SELECT COUNT(*) as total FROM proyectos WHERE estudiante_id = ? AND estado = 'aprobado'";
                PreparedStatement pstmt2 = conn.prepareStatement(sql2);
                pstmt2.setString(1, usuarioId);
                ResultSet rs2 = pstmt2.executeQuery();
                if (rs2.next()) proyectosAprobados = rs2.getInt("total");
                
                conn.close();
            } catch (Exception e) {
                out.println("<!-- Error: " + e.getMessage() + " -->");
            }
            %>
            
            <div class="stat-card">
                <span class="stat-number"><%= proyectosActivos %></span>
                <span class="stat-label">Proyectos Activos</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= entregasPendientes %></span>
                <span class="stat-label">Entregas Pendientes</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= proyectosAprobados %></span>
                <span class="stat-label">Proyectos Aprobados</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= proyectosActivos > 0 ? "50%" : "0%" %></span>
                <span class="stat-label">Progreso General</span>
            </div>
        </div>

        <!-- Acciones del Estudiante -->
        <div class="role-cards">
            <div class="role-card">
                <h3>💡 Proponer Idea</h3>
                <p>Prop&#243;n una nueva idea de proyecto para desarrollar como trabajo de grado</p>
                <a href="proponerIdea.jsp" class="btn btn-uts">Proponer Idea</a>
            </div>
            
            <div class="role-card">
                <h3>📤 Subir Anteproyecto</h3>
                <p>Sube tu documento de anteproyecto para revisi&#243;n del director</p>
                <a href="subirAnteproyecto.jsp" class="btn btn-info">Subir Anteproyecto</a>
            </div>
            
            <div class="role-card">
                <h3>📋 Mis Proyectos</h3>
                <p>Consulta el estado y detalles de todos tus proyectos</p>
                <a href="misProyectos.jsp" class="btn btn-success">Ver Proyectos</a>
            </div>
            
            <div class="role-card">
                <h3>📊 Historial de Versiones</h3>
                <p>Revisa el historial de versiones y correcciones de tus anteproyectos</p>
                <a href="historialVersiones.jsp" class="btn btn-warning">Ver Historial</a>
            </div>
        </div>

        <!-- Proyectos Recientes -->
        <div style="margin-top: 40px;">
            <h3 style="color: var(--uts-red); margin-bottom: 20px;">📁 Mis Proyectos Recientes</h3>
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>T&#237;tulo</th>
                            <th>Estado</th>
                            <th>Director</th>
                            <th>Fecha</th>
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
                            
                            String sql = "SELECT p.*, u.nombre as director_nombre FROM proyectos p LEFT JOIN usuarios u ON p.director_id = u.id WHERE p.estudiante_id = ? ORDER BY p.fecha_creacion DESC LIMIT 3";
                            PreparedStatement pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, usuarioId);
                            ResultSet rs = pstmt.executeQuery();
                            
                            while (rs.next()) {
                                String estado = rs.getString("estado");
                                String estadoClass = "estado-" + estado;
                        %>
                        <tr>
                            <td><strong><%= rs.getString("titulo") %></strong></td>
                            <td><span class="<%= estadoClass %>"><%= estado.toUpperCase() %></span></td>
                            <td><%= rs.getString("director_nombre") != null ? rs.getString("director_nombre") : "No asignado" %></td>
                            <td><%= rs.getString("fecha_creacion") %></td>
                            <td>
                                <a href="subirAnteproyecto.jsp?proyecto_id=<%= rs.getInt("id") %>" class="btn btn-info" style="padding: 5px 10px; font-size: 0.8em;">Subir</a>
                                <a href="historialVersiones.jsp?proyecto_id=<%= rs.getInt("id") %>" class="btn" style="padding: 5px 10px; font-size: 0.8em; background: var(--uts-blue);">Ver</a>
                            </td>
                        </tr>
                        <%
                            }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5'>No tienes proyectos registrados</td></tr>");
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