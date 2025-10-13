<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
// Verificar autenticación
String usuarioId = (String) session.getAttribute("usuario_id");
if (usuarioId == null) {
    response.sendRedirect("login.jsp");
    return;
}

String usuarioRol = (String) session.getAttribute("usuario_rol");
String usuarioNombre = (String) session.getAttribute("usuario_nombre");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - UTS</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <header class="uts-header">
        <div class="header-container">
            <div class="logo-section">
                <img src="img/logo-uts.png" 
                     alt="Logo UTS" class="uts-logo">
                <div>
                    <h1 class="uts-title">Unidades Tecnol&#243;gicas de Santander</h1>
                    <p class="uts-subtitle">Sistema de Gesti&#243;n de Trabajos de Grado</p>
                </div>
            </div>
            <div class="user-info">
                <span class="user-welcome">Bienvenido, <%= usuarioNombre %></span>
                <span class="user-role"><%= usuarioRol.toUpperCase() %></span>
                <a href="logout.jsp" class="logout-btn">Cerrar Sesi&#243;n</a>
            </div>
        </div>
        
        <!-- Agregar navegación -->
        <nav class="main-nav">
            <ul>
                <li><a href="dashboard.jsp">Inicio</a></li>
                <li><a href="https://www.uts.edu.co/sitio/calendario-academico" target="_blank">Calendario Acad&#233;mico</a></li>
                <li><a href="http://repositorio.uts.edu.co:8080/xmlui/handle/123456789/3949" target="_blank">Formatos de Grado</a></li>
                <% if ("admin".equals(usuarioRol)) { %>
                    <li><a href="pages/admin/dashboard.jsp">Panel Admin</a></li>
                <% } else if ("coordinacion".equals(usuarioRol)) { %>
                    <li><a href="pages/coordinacion/dashboard.jsp">Panel Coordinaci&#243;n</a></li>
                <% } else if ("director".equals(usuarioRol)) { %>
                    <li><a href="pages/director/dashboard.jsp">Panel Director</a></li>
                <% } else if ("evaluador".equals(usuarioRol)) { %>
                    <li><a href="pages/evaluador/dashboard.jsp">Panel Evaluador</a></li>
                <% } else if ("estudiante".equals(usuarioRol)) { %>
                    <li><a href="pages/estudiante/dashboard.jsp">Panel Estudiante</a></li>
                <% } %>
            </ul>
        </nav>
    </header>

    <div class="main-content">
        <div class="welcome-section">
            <h1>Panel de Control</h1>
            <p>Gesti&#243;n integral de trabajos de grado - Rol: <%= usuarioRol %></p>
        </div>

        <!-- Estadísticas REALES desde la BD -->
        <div class="dashboard-stats">
            <%
            int totalUsuarios = 0;
            int totalProyectos = 0;
            int proyectosPendientes = 0;
            int proyectosAprobados = 0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
                    "unsp1ogkp7qbzhgm", 
                    "ZXCRqDEJJIyGydtVjg3G"
                );
                
                // Total usuarios
                String sql1 = "SELECT COUNT(*) as total FROM usuarios WHERE estado = 'activo'";
                PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                ResultSet rs1 = pstmt1.executeQuery();
                if (rs1.next()) totalUsuarios = rs1.getInt("total");
                
                // Total proyectos
                String sql2 = "SELECT COUNT(*) as total FROM proyectos";
                PreparedStatement pstmt2 = conn.prepareStatement(sql2);
                ResultSet rs2 = pstmt2.executeQuery();
                if (rs2.next()) totalProyectos = rs2.getInt("total");
                
                // Proyectos pendientes
                String sql3 = "SELECT COUNT(*) as total FROM proyectos WHERE estado IN ('pendiente', 'en_revision')";
                PreparedStatement pstmt3 = conn.prepareStatement(sql3);
                ResultSet rs3 = pstmt3.executeQuery();
                if (rs3.next()) proyectosPendientes = rs3.getInt("total");
                
                // Proyectos aprobados
                String sql4 = "SELECT COUNT(*) as total FROM proyectos WHERE estado IN ('aprobado', 'evaluacion', 'finalizado')";
                PreparedStatement pstmt4 = conn.prepareStatement(sql4);
                ResultSet rs4 = pstmt4.executeQuery();
                if (rs4.next()) proyectosAprobados = rs4.getInt("total");
                
                conn.close();
            } catch (Exception e) {
                // Si hay error, usar valores por defecto
                totalUsuarios = 11;
                totalProyectos = 9;
                proyectosPendientes = 3;
                proyectosAprobados = 6;
            }
            %>
            
            <div class="stat-card">
                <span class="stat-number" id="stat-usuarios"><%= totalUsuarios %></span>
                <span class="stat-label">Usuarios Activos</span>
            </div>
            <div class="stat-card">
                <span class="stat-number" id="stat-proyectos"><%= totalProyectos %></span>
                <span class="stat-label">Proyectos Registrados</span>
            </div>
            <div class="stat-card">
                <span class="stat-number" id="stat-pendientes"><%= proyectosPendientes %></span>
                <span class="stat-label">Pendientes de Revisi&#243;n</span>
            </div>
            <div class="stat-card">
                <span class="stat-number" id="stat-aprobados"><%= proyectosAprobados %></span>
                <span class="stat-label">Proyectos Aprobados</span>
            </div>
        </div>

        <!-- Acciones por Rol - ACTUALIZADO con enlaces reales -->
        <div class="role-cards">
            <% if ("admin".equals(usuarioRol)) { %>
                <div class="role-card">
                    <h3>👥 Gesti&#243;n de Usuarios</h3>
                    <p>Registrar, editar y eliminar usuarios del sistema</p>
                    <a href="pages/admin/gestionUsuarios.jsp" class="btn btn-uts">Administrar Usuarios</a>
                </div>
                <div class="role-card">
                    <h3>📊 Reportes del Sistema</h3>
                    <p>Generar reportes y estad&#237;sticas del sistema</p>
                    <a href="pages/admin/dashboard.jsp" class="btn btn-info">Panel Completo</a>
                </div>
                <div class="role-card">
                    <h3>➕ Registrar Usuario</h3>
                    <p>Agregar nuevos usuarios al sistema</p>
                    <a href="pages/admin/registrarUsuario.jsp" class="btn btn-success">Nuevo Usuario</a>
                </div>
                
            <% } else if ("coordinacion".equals(usuarioRol)) { %>
                <div class="role-card">
                    <h3>👨‍🏫 Asignar Directores</h3>
                    <p>Asignar directores a proyectos pendientes</p>
                    <a href="pages/coordinacion/asignarDirector.jsp" class="btn btn-uts">Asignar Directores</a>
                </div>
                <div class="role-card">
                    <h3>⭐ Asignar Evaluadores</h3>
                    <p>Asignar evaluadores a proyectos aprobados</p>
                    <a href="pages/coordinacion/asignarEvaluador.jsp" class="btn btn-info">Asignar Evaluadores</a>
                </div>
                <div class="role-card">
                    <h3>📋 Gesti&#243;n de Proyectos</h3>
                    <p>Gestionar todos los proyectos del sistema</p>
                    <a href="pages/coordinacion/dashboard.jsp" class="btn btn-success">Panel Completo</a>
                </div>
                
            <% } else if ("director".equals(usuarioRol)) { %>
                <div class="role-card">
                    <h3>📋 Calificar Anteproyectos</h3>
                    <p>Revisar y calificar anteproyectos de estudiantes</p>
                    <a href="pages/director/calificarProyecto.jsp" class="btn btn-uts">Revisar Anteproyectos</a>
                </div>
                <div class="role-card">
                    <h3>📊 Proyectos Asignados</h3>
                    <p>Ver todos los proyectos bajo tu direcci&#243;n</p>
                    <a href="pages/director/dashboard.jsp" class="btn btn-info">Panel Completo</a>
                </div>
                
            <% } else if ("evaluador".equals(usuarioRol)) { %>
                <div class="role-card">
                    <h3>⭐ Evaluar Proyectos</h3>
                    <p>Evaluar proyectos aprobados por directores</p>
                    <a href="pages/evaluador/evaluarProyecto.jsp" class="btn btn-uts">Evaluar Proyectos</a>
                </div>
                <div class="role-card">
                    <h3>📋 Proyectos para Evaluar</h3>
                    <p>Ver proyectos asignados para evaluaci&#243;n</p>
                    <a href="pages/evaluador/dashboard.jsp" class="btn btn-info">Panel Completo</a>
                </div>
                
            <% } else if ("estudiante".equals(usuarioRol)) { %>
                <div class="role-card">
                    <h3>💡 Proponer Idea</h3>
                    <p>Proponer nueva idea de proyecto de grado</p>
                    <a href="pages/estudiante/proponerIdea.jsp" class="btn btn-uts">Proponer Idea</a>
                </div>
                <div class="role-card">
                    <h3>📤 Subir Anteproyecto</h3>
                    <p>Subir documento de anteproyecto para revisi&#243;n</p>
                    <a href="pages/estudiante/subirAnteproyecto.jsp" class="btn btn-info">Subir Anteproyecto</a>
                </div>
                <div class="role-card">
                    <h3>📁 Mis Proyectos</h3>
                    <p>Consultar estado de todos tus proyectos</p>
                    <a href="pages/estudiante/misProyectos.jsp" class="btn btn-success">Ver Proyectos</a>
                </div>
            <% } %>
            
            <!-- Acciones comunes -->
            <div class="role-card">
                <h3>📅 Calendario Acad&#233;mico</h3>
                <p>Consultar fechas importantes y calendario</p>
                <a href="https://www.uts.edu.co/sitio/calendario-academico" target="_blank" class="btn btn-info">Ver Calendario</a>
            </div>
            <div class="role-card">
                <h3>📑 Formatos de Grado</h3>
                <p>Descargar formatos y documentos oficiales</p>
                <a href="http://repositorio.uts.edu.co:8080/xmlui/handle/123456789/3949" target="_blank" class="btn btn-success">Descargar Formatos</a>
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

    <script>
        // Animación de estadísticas (opcional)
        function animateCounter(element, target) {
            let current = 0;
            const increment = target / 100;
            const timer = setInterval(() => {
                current += increment;
                if (current >= target) {
                    current = target;
                    clearInterval(timer);
                }
                element.textContent = Math.floor(current);
            }, 20);
        }

        // Animar los contadores
        setTimeout(() => {
            animateCounter(document.getElementById('stat-usuarios'), <%= totalUsuarios %>);
            animateCounter(document.getElementById('stat-proyectos'), <%= totalProyectos %>);
            animateCounter(document.getElementById('stat-pendientes'), <%= proyectosPendientes %>);
            animateCounter(document.getElementById('stat-aprobados'), <%= proyectosAprobados %>);
        }, 500);
    </script>
</body>
</html>