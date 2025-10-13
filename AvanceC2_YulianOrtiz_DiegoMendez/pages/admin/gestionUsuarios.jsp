<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gesti&#243;n de Usuarios - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<% 
// Mostrar mensajes de éxito o error
String success = request.getParameter("success");
String error = request.getParameter("error");

if (success != null) {
    if ("usuario_creado".equals(success)) {
        out.println("<div class='alert alert-success'>✅ Usuario creado exitosamente</div>");
    } else if ("usuario_actualizado".equals(success)) {
        out.println("<div class='alert alert-success'>✅ Usuario actualizado exitosamente</div>");
    } else if ("usuario_eliminado".equals(success)) {
        out.println("<div class='alert alert-success'>✅ Usuario eliminado exitosamente</div>");
    } else if ("usuario_inactivado".equals(success)) {
        out.println("<div class='alert alert-success'>✅ Usuario marcado como inactivo (tenía proyectos asociados)</div>");
    }
}

if (error != null) {
    if ("usuario_no_encontrado".equals(error)) {
        out.println("<div class='alert alert-error'>❌ Usuario no encontrado</div>");
    } else {
        out.println("<div class='alert alert-error'>❌ Error: " + error + "</div>");
    }
}
%>
<body>
    <%@ include file="../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <div class="welcome-section">
            <h1>👥 Gesti&#243;n de Usuarios</h1>
            <p>Administra los usuarios del sistema</p>
        </div>

        <div style="text-align: right; margin-bottom: 20px;">
            <a href="registrarUsuario.jsp" class="btn btn-success">➕ Nuevo Usuario</a>
            <a href="dashboard.jsp" class="btn btn-uts">🏠 Volver al Dashboard</a>
        </div>

        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>C&#233;dula</th>
                        <th>Nombre</th>
                        <th>Email</th>
                        <th>Rol</th>
                        <th>&#193;rea</th>
                        <th>Estado</th>
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
                        
                        String sql = "SELECT * FROM usuarios ORDER BY fecha_creacion DESC";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("cedula") %></td>
                        <td><%= rs.getString("nombre") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td>
                            <span class="user-role" style="font-size: 0.8em;">
                                <%= rs.getString("rol").toUpperCase() %>
                            </span>
                        </td>
                        <td><%= rs.getString("area_conocimiento") != null ? rs.getString("area_conocimiento") : "N/A" %></td>
                        <td>
                            <span style="color: <%= "activo".equals(rs.getString("estado")) ? "green" : "red" %>; font-weight: bold;">
                                <%= rs.getString("estado").toUpperCase() %>
                            </span>
                        </td>
                        <td>
                            <a href="editarUsuario.jsp?id=<%= rs.getInt("id") %>" class="btn btn-info" style="padding: 5px 10px; font-size: 0.8em;">Editar</a>
                            <a href="eliminarUsuario.jsp?id=<%= rs.getInt("id") %>" class="btn" style="padding: 5px 10px; font-size: 0.8em; background: #dc3545;" 
                               onclick="return confirm('&#191;Est&#225; seguro de eliminar este usuario?')">Eliminar</a>
                        </td>
                    </tr>
                    <%
                        }
                        conn.close();
                    } catch (Exception e) {
                        out.println("<tr><td colspan='7'>Error: " + e.getMessage() + "</td></tr>");
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <%@ include file="../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>