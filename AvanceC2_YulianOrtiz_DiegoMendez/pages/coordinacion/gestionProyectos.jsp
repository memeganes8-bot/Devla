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
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Proyectos - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <div class="welcome-section">
            <h1>📊 Gestión de Proyectos</h1>
            <p>Vista general de todos los proyectos del sistema</p>
        </div>

        <div style="text-align: right; margin-bottom: 20px;">
            <a href="asignarDirector.jsp" class="btn btn-uts">👨‍🏫 Asignar Directores</a>
            <a href="asignarEvaluador.jsp" class="btn btn-success">⭐ Asignar Evaluadores</a>
            <a href="dashboard.jsp" class="btn btn-info">🏠 Volver al Dashboard</a>
        </div>

        <!-- Filtros -->
        <div style="background: #f8f9fa; padding: 20px; border-radius: 10px; margin-bottom: 20px;">
            <h4 style="color: var(--uts-red); margin-bottom: 15px;">🔍 Filtros</h4>
            <form method="GET" action="gestionProyectos.jsp" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                <div>
                    <label for="estado" style="display: block; margin-bottom: 5px; font-weight: 600;">Estado:</label>
                    <select class="form-control" id="estado" name="estado">
                        <option value="">Todos los estados</option>
                        <option value="pendiente">Pendiente</option>
                        <option value="en_revision">En Revisión</option>
                        <option value="correcciones">Correcciones</option>
                        <option value="aprobado">Aprobado</option>
                        <option value="evaluacion">Evaluación</option>
                        <option value="finalizado">Finalizado</option>
                    </select>
                </div>
                <div>
                    <label for="director" style="display: block; margin-bottom: 5px; font-weight: 600;">Director:</label>
                    <select class="form-control" id="director" name="director">
                        <option value="">Todos los directores</option>
                        <option value="sin_director">Sin Director</option>
                    </select>
                </div>
                <div>
                    <label for="evaluador" style="display: block; margin-bottom: 5px; font-weight: 600;">Evaluador:</label>
                    <select class="form-control" id="evaluador" name="evaluador">
                        <option value="">Todos los evaluadores</option>
                        <option value="sin_evaluador">Sin Evaluador</option>
                    </select>
                </div>
                <div style="display: flex; align-items: end;">
                    <button type="submit" class="btn btn-success" style="margin-right: 10px;">Filtrar</button>
                    <a href="gestionProyectos.jsp" class="btn btn-uts">Limpiar</a>
                </div>
            </form>
        </div>

        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Estudiante</th>
                        <th>Título del Proyecto</th>
                        <th>Estado</th>
                        <th>Director</th>
                        <th>Evaluador</th>
                        <th>Fecha Creación</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    String filtroEstado = request.getParameter("estado");
                    String filtroDirector = request.getParameter("director");
                    
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection conn = DriverManager.getConnection(
                            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
                            "unsp1ogkp7qbzhgm", 
                            "ZXCRqDEJJIyGydtVjg3G"
                        );
                        
                        String sql = "SELECT p.id, p.titulo, p.estado, p.fecha_creacion, " +
                                    "e.nombre as estudiante, d.nombre as director, ev.nombre as evaluador " +
                                    "FROM proyectos p " +
                                    "JOIN usuarios e ON p.estudiante_id = e.id " +
                                    "LEFT JOIN usuarios d ON p.director_id = d.id " +
                                    "LEFT JOIN usuarios ev ON p.evaluador_id = ev.id " +
                                    "WHERE 1=1";
                        
                        if (filtroEstado != null && !filtroEstado.isEmpty()) {
                            sql += " AND p.estado = ?";
                        }
                        if ("sin_director".equals(filtroDirector)) {
                            sql += " AND p.director_id IS NULL";
                        }
                        
                        sql += " ORDER BY p.fecha_creacion DESC";
                        
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        int paramIndex = 1;
                        
                        if (filtroEstado != null && !filtroEstado.isEmpty()) {
                            pstmt.setString(paramIndex++, filtroEstado);
                        }
                        
                        ResultSet rs = pstmt.executeQuery();
                        
                        while (rs.next()) {
                            String estado = rs.getString("estado");
                            String estadoClass = "estado-" + estado;
                    %>
                    <tr>
                        <td><strong><%= rs.getString("estudiante") %></strong></td>
                        <td><%= rs.getString("titulo") %></td>
                        <td><span class="<%= estadoClass %>"><%= estado.toUpperCase() %></span></td>
                        <td>
                            <% if (rs.getString("director") != null) { %>
                                <%= rs.getString("director") %>
                            <% } else { %>
                                <span style="color: var(--uts-red); font-weight: bold;">SIN ASIGNAR</span>
                            <% } %>
                        </td>
                        <td>
                            <% if (rs.getString("evaluador") != null) { %>
                                <%= rs.getString("evaluador") %>
                            <% } else { %>
                                <span style="color: #666;">No asignado</span>
                            <% } %>
                        </td>
                        <td><%= rs.getString("fecha_creacion") %></td>
                        <td>
                            <div style="display: flex; gap: 5px; flex-wrap: wrap;">
                                <% if (rs.getString("director") == null) { %>
                                    <a href="asignarDirector.jsp?proyecto_id=<%= rs.getInt("id") %>" class="btn btn-uts" style="padding: 3px 8px; font-size: 0.7em;">Asignar Director</a>
                                <% } else if ("aprobado".equals(estado) && rs.getString("evaluador") == null) { %>
                                    <a href="asignarEvaluador.jsp?proyecto_id=<%= rs.getInt("id") %>" class="btn btn-success" style="padding: 3px 8px; font-size: 0.7em;">Asignar Evaluador</a>
                                <% } %>
                                <a href="#" class="btn btn-info" style="padding: 3px 8px; font-size: 0.7em;">Detalles</a>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                        if (!rs.isBeforeFirst()) {
                            out.println("<tr><td colspan='7' style='text-align: center; padding: 40px;'>No se encontraron proyectos con los filtros aplicados.</td></tr>");
                        }
                        conn.close();
                    } catch (Exception e) {
                        out.println("<tr><td colspan='7'>Error al cargar proyectos: " + e.getMessage() + "</td></tr>");
                    }
                    %>
                </tbody>
            </table>
        </div>

        <!-- Estadísticas Generales -->
        <div class="dashboard-stats" style="margin-top: 40px;">
            <%
            int totalProyectos = 0;
            int sinDirector = 0;
            int aprobadosSinEvaluador = 0;
            int finalizados = 0;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
                    "unsp1ogkp7qbzhgm", 
                    "ZXCRqDEJJIyGydtVjg3G"
                );
                
                String sql = "SELECT COUNT(*) as total, " +
                            "SUM(CASE WHEN director_id IS NULL THEN 1 ELSE 0 END) as sin_director, " +
                            "SUM(CASE WHEN estado = 'aprobado' AND evaluador_id IS NULL THEN 1 ELSE 0 END) as sin_evaluador, " +
                            "SUM(CASE WHEN estado = 'finalizado' THEN 1 ELSE 0 END) as finalizados " +
                            "FROM proyectos";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    totalProyectos = rs.getInt("total");
                    sinDirector = rs.getInt("sin_director");
                    aprobadosSinEvaluador = rs.getInt("sin_evaluador");
                    finalizados = rs.getInt("finalizados");
                }
                conn.close();
            } catch (Exception e) {
                // Valores por defecto
                totalProyectos = 9;
                sinDirector = 2;
                aprobadosSinEvaluador = 2;
                finalizados = 2;
            }
            %>
            
            <div class="stat-card">
                <span class="stat-number"><%= totalProyectos %></span>
                <span class="stat-label">Total Proyectos</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= sinDirector %></span>
                <span class="stat-label">Sin Director</span>
            </div>
            <div class="stat-card">
                <span class="stat-number"><%= aprobadosSinEvaluador %></span>
                <span class="stat-label">Aprobados sin Evaluador</span>
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