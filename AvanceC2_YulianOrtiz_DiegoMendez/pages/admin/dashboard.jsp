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

if (!"admin".equals(usuarioRol)) {
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
    <title>Dashboard Administrador - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <header class="uts-header">
        <div class="header-container">
            <div class="logo-section">
                <img src="../../img/logo-uts.png" alt="Logo UTS" class="uts-logo">
                <div>
                    <h1 class="uts-title">Unidades Tecnol&#243;gicas de Santander</h1>
                    <p class="uts-subtitle">Panel de Administraci&#243;n</p>
                </div>
            </div>
            <div class="user-info">
                <span class="user-welcome">Bienvenido, <%= usuarioNombre %></span>
                <span class="user-role">ADMIN</span>
                <a href="../../logout.jsp" class="logout-btn">Cerrar Sesi&#243;n</a>
            </div>
        </div>
        
        <nav class="main-nav">
            <ul>
                <li><a href="dashboard.jsp">Dashboard</a></li>
                <li><a href="gestionUsuarios.jsp">Gesti&#243;n de Usuarios</a></li>
                <li><a href="registrarUsuario.jsp">Registrar Usuario</a></li>
                <li><a href="https://www.uts.edu.co/sitio/calendario-academico" target="_blank">Calendario Acad&#233;mico</a></li>
                <li><a href="http://repositorio.uts.edu.co:8080/xmlui/handle/123456789/3949" target="_blank">Formatos de Grado</a></li>
            </ul>
        </nav>
    </header>

    <div class="main-content">
        <div class="welcome-section">
            <h1>🏠 Panel de Administraci&#243;n</h1>
            <p>Gesti&#243;n completa del sistema de trabajos de grado</p>
        </div>

        <!-- Estadísticas -->
        <div class="dashboard-stats">
            <%
            int totalUsuarios = 0;
            int totalEstudiantes = 0;
            int totalProfesores = 0;
            int usuariosActivos = 0;
            int totalProyectos = 0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
                    "unsp1ogkp7qbzhgm", 
                    "ZXCRqDEJJIyGydtVjg3G"
                );
                
                // Total usuarios
                String sql1 = "SELECT COUNT(*) as total FROM usuarios";
                PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                ResultSet rs1 = pstmt1.executeQuery();
                if (rs1.next()) totalUsuarios = rs1.getInt("total");
                
                // Total estudiantes
                String sql2 = "SELECT COUNT(*) as total FROM usuarios WHERE rol = 'estudiante'";
                PreparedStatement pstmt2 = conn.prepareStatement(sql2);
                ResultSet rs2 = pstmt2.executeQuery();
                if (rs2.next()) totalEstudiantes = rs2.getInt("total");
                
                // Total profesores
                String sql3 = "SELECT COUNT(*) as total FROM usuarios WHERE rol IN ('director', 'evaluador', 'coordinacion')";
                PreparedStatement pstmt3 = conn.prepareStatement(sql3);
                ResultSet rs3 = pstmt3.executeQuery();
                if (rs3.next()) totalProfesores = rs3.getInt("total");
                
                // Usuarios activos
                String sql4 = "SELECT COUNT(*) as total FROM usuarios WHERE estado = 'activo'";
                PreparedStatement pstmt4 = conn.prepareStatement(sql4);
                ResultSet rs4 = pstmt4.executeQuery();
                if (rs4.next()) usuariosActivos = rs4.getInt("total");
                
                // Total proyectos
                String sql5 = "SELECT COUNT(*) as total FROM proyectos";
                PreparedStatement pstmt5 = conn.prepareStatement(sql5);
                ResultSet rs5 = pstmt5.executeQuery();
                if (rs5.next()) totalProyectos = rs5.getInt("total");
                
                conn.close();
            } catch (Exception e) {
                out.println("<!-- Error: " + e.getMessage() + " -->");
            }
            %>
            
            <div class="stat-card">
                <span class="stat-number"><%= totalUsuarios %></span>
                <span class="stat-label">Total Usuarios</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= totalEstudiantes %></span>
                <span class="stat-label">Estudiantes</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= totalProfesores %></span>
                <span class="stat-label">Profesores</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= totalProyectos %></span>
                <span class="stat-label">Proyectos</span>
            </div>
        </div>

        <!-- Acciones Rápidas -->
        <div class="role-cards">
            <div class="role-card">
                <h3>👥 Gesti&#243;n de Usuarios</h3>
                <p>Registrar, editar y eliminar usuarios del sistema. Control total de acceso.</p>
                <a href="gestionUsuarios.jsp" class="btn btn-uts">Administrar Usuarios</a>
            </div>
            
            <div class="role-card">
                <h3>➕ Registrar Usuario</h3>
                <p>Agregar nuevos usuarios al sistema con diferentes roles y permisos.</p>
                <a href="registrarUsuario.jsp" class="btn btn-success">Nuevo Usuario</a>
            </div>
            
            <div class="role-card">
                <h3>📊 Reportes del Sistema</h3>
                <p>Generar reportes detallados y estad&#237;sticas del sistema.</p>
                <a href="#" class="btn btn-info">Ver Reportes</a>
            </div>
            
            <div class="role-card">
                <h3>⚙️ Configuraci&#243;n</h3>
                <p>Configurar par&#225;metros del sistema y preferencias.</p>
                <a href="#" class="btn" style="background: var(--uts-gray);">Configurar</a>
            </div>
        </div>

        <!-- Usuarios Recientes -->
        <div style="margin-top: 40px;">
            <h3 style="color: var(--uts-red); margin-bottom: 20px;">📋 Usuarios Recientes</h3>
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Nombre</th>
                            <th>Email</th>
                            <th>Rol</th>
                            <th>Estado</th>
                            <th>Fecha Registro</th>
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
                            
                            String sql = "SELECT nombre, email, rol, estado, fecha_creacion FROM usuarios ORDER BY fecha_creacion DESC LIMIT 5";
                            PreparedStatement pstmt = conn.prepareStatement(sql);
                            ResultSet rs = pstmt.executeQuery();
                            
                            while (rs.next()) {
                        %>
                        <tr>
                            <td><%= rs.getString("nombre") %></td>
                            <td><%= rs.getString("email") %></td>
                            <td>
                                <span class="user-role" style="font-size: 0.8em;">
                                    <%= rs.getString("rol").toUpperCase() %>
                                </span>
                            </td>
                            <td>
                                <span style="color: <%= "activo".equals(rs.getString("estado")) ? "green" : "red" %>; font-weight: bold;">
                                    <%= rs.getString("estado").toUpperCase() %>
                                </span>
                            </td>
                            <td><%= rs.getString("fecha_creacion") %></td>
                        </tr>
                        <%
                            }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5'>Error al cargar usuarios: " + e.getMessage() + "</td></tr>");
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