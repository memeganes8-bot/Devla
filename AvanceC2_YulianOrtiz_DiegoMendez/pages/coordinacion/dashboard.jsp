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

String usuarioNombre = (String) session.getAttribute("usuario_nombre");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Coordinaci&#243;n - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <header class="uts-header">
        <div class="header-container">
            <div class="logo-section">
                <img src="../../img/logo-uts.png" alt="Logo UTS" class="uts-logo">
                <div>
                    <h1 class="uts-title">Unidades Tecnol&#243;gicas de Santander</h1>
                    <p class="uts-subtitle">Panel de Coordinaci&#243;n</p>
                </div>
            </div>
            <div class="user-info">
                <span class="user-welcome">Bienvenido, <%= usuarioNombre %></span>
                <span class="user-role">COORDINACI&#211;N</span>
                <a href="../../logout.jsp" class="logout-btn">Cerrar Sesi&#243;n</a>
            </div>
        </div>
        
        <nav class="main-nav">
            <ul>
                <li><a href="dashboard.jsp">Dashboard</a></li>
                <li><a href="gestionProyectos.jsp">Gesti&#243;n de Proyectos</a></li>
                <li><a href="asignarDirector.jsp">Asignar Directores</a></li>
                <li><a href="asignarEvaluador.jsp">Asignar Evaluadores</a></li>
                <li><a href="https://www.uts.edu.co/sitio/calendario-academico" target="_blank">Calendario Acad&#233;mico</a></li>
                <li><a href="http://repositorio.uts.edu.co:8080/xmlui/handle/123456789/3949" target="_blank">Formatos de Grado</a></li>
            </ul>
        </nav>
    </header>

    <div class="main-content">
        <div class="welcome-section">
            <h1>📊 Panel de Coordinaci&#243;n</h1>
            <p>Gesti&#243;n general de proyectos y asignaci&#243;n de roles</p>
        </div>

        <!-- Estadísticas de Coordinación -->
        <div class="dashboard-stats">
            <%
            int totalProyectos = 0;
            int proyectosSinDirector = 0;
            int proyectosAprobados = 0;
            int proyectosSinEvaluador = 0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
                    "unsp1ogkp7qbzhgm", 
                    "ZXCRqDEJJIyGydtVjg3G"
                );
                
                // Total proyectos
                String sql1 = "SELECT COUNT(*) as total FROM proyectos";
                PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                ResultSet rs1 = pstmt1.executeQuery();
                if (rs1.next()) totalProyectos = rs1.getInt("total");
                
                // Proyectos sin director
                String sql2 = "SELECT COUNT(*) as total FROM proyectos WHERE director_id IS NULL";
                PreparedStatement pstmt2 = conn.prepareStatement(sql2);
                ResultSet rs2 = pstmt2.executeQuery();
                if (rs2.next()) proyectosSinDirector = rs2.getInt("total");
                
                // Proyectos aprobados
                String sql3 = "SELECT COUNT(*) as total FROM proyectos WHERE estado = 'aprobado'";
                PreparedStatement pstmt3 = conn.prepareStatement(sql3);
                ResultSet rs3 = pstmt3.executeQuery();
                if (rs3.next()) proyectosAprobados = rs3.getInt("total");
                
                // Proyectos sin evaluador
                String sql4 = "SELECT COUNT(*) as total FROM proyectos WHERE estado = 'aprobado' AND evaluador_id IS NULL";
                PreparedStatement pstmt4 = conn.prepareStatement(sql4);
                ResultSet rs4 = pstmt4.executeQuery();
                if (rs4.next()) proyectosSinEvaluador = rs4.getInt("total");
                
                conn.close();
            } catch (Exception e) {
                out.println("<!-- Error: " + e.getMessage() + " -->");
            }
            %>
            
            <div class="stat-card">
                <span class="stat-number"><%= totalProyectos %></span>
                <span class="stat-label">Total Proyectos</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= proyectosSinDirector %></span>
                <span class="stat-label">Sin Director</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= proyectosAprobados %></span>
                <span class="stat-label">Aprobados</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= proyectosSinEvaluador %></span>
                <span class="stat-label">Sin Evaluador</span>
            </div>
        </div>

        <!-- Acciones de Coordinación -->
        <div class="role-cards">
            <div class="role-card">
                <h3>👨‍🏫 Asignar Directores</h3>
                <p>Asigna directores a proyectos que no tienen director asignado</p>
                <a href="asignarDirector.jsp" class="btn btn-uts">Asignar Directores</a>
            </div>
            
            <div class="role-card">
                <h3>⭐ Asignar Evaluadores</h3>
                <p>Asigna evaluadores a proyectos aprobados por directores</p>
                <a href="asignarEvaluador.jsp" class="btn btn-success">Asignar Evaluadores</a>
            </div>
            
            <div class="role-card">
                <h3>📋 Gesti&#243;n de Proyectos</h3>
                <p>Consulta y gestiona todos los proyectos del sistema</p>
                <a href="gestionProyectos.jsp" class="btn btn-info">Gestionar Proyectos</a>
            </div>
            
            <div class="role-card">
                <h3>📊 Reportes Generales</h3>
                <p>Genera reportes y estad&#237;sticas del sistema</p>
                <a href="#" class="btn btn-warning">Ver Reportes</a>
            </div>
        </div>

        <!-- Proyectos que Requieren Atención -->
        <div style="margin-top: 40px;">
            <h3 style="color: var(--uts-red); margin-bottom: 20px;">⚠️ Proyectos que Requieren Atenci&#243;n</h3>
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Estudiante</th>
                            <th>T&#237;tulo del Proyecto</th>
                            <th>Estado</th>
                            <th>Acci&#243;n Requerida</th>
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
                            
                            // Proyectos sin director
                            String sql = "SELECT p.id, p.titulo, u.nombre as estudiante, p.estado, 'asignar_director' as accion " +
                                        "FROM proyectos p JOIN usuarios u ON p.estudiante_id = u.id " +
                                        "WHERE p.director_id IS NULL " +
                                        "UNION " +
                                        "SELECT p.id, p.titulo, u.nombre as estudiante, p.estado, 'asignar_evaluador' as accion " +
                                        "FROM proyectos p JOIN usuarios u ON p.estudiante_id = u.id " +
                                        "WHERE p.estado = 'aprobado' AND p.evaluador_id IS NULL " +
                                        "LIMIT 5";
                            PreparedStatement pstmt = conn.prepareStatement(sql);
                            ResultSet rs = pstmt.executeQuery();
                            
                            while (rs.next()) {
                                String accion = rs.getString("accion");
                                String textoAccion = "Asignar Director";
                                String linkAccion = "asignarDirector.jsp";
                                String colorBoton = "btn-uts";
                                
                                if ("asignar_evaluador".equals(accion)) {
                                    textoAccion = "Asignar Evaluador";
                                    linkAccion = "asignarEvaluador.jsp";
                                    colorBoton = "btn-success";
                                }
                        %>
                        <tr>
                            <td><strong><%= rs.getString("estudiante") %></strong></td>
                            <td><%= rs.getString("titulo") %></td>
                            <td><span class="estado-<%= rs.getString("estado") %>"><%= rs.getString("estado").toUpperCase() %></span></td>
                            <td><strong><%= textoAccion %></strong></td>
                            <td>
                                <a href="<%= linkAccion %>?proyecto_id=<%= rs.getInt("id") %>" class="btn <%= colorBoton %>" style="padding: 5px 10px; font-size: 0.8em;">
                                    <%= textoAccion %>
                                </a>
                            </td>
                        </tr>
                        <%
                            }
                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='5'>No hay proyectos que requieran atenci&#243;n inmediata</td></tr>");
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