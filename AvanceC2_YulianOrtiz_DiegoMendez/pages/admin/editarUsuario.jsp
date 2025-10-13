<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Editar Usuario - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../WEB-INF/jspf/header.jspf" %>

    <%
    // Verificar autenticación y rol de admin - DESPUÉS del header
    String usuarioRolActual = (String) session.getAttribute("usuario_rol");
    if (usuarioRolActual == null || !"admin".equals(usuarioRolActual)) {
        response.sendRedirect("../../login.jsp");
        return;
    }

    String usuarioId = request.getParameter("id");
    String mensaje = "";

    if (usuarioId == null) {
        response.sendRedirect("gestionUsuarios.jsp?error=usuario_no_encontrado");
        return;
    }

    // Cargar datos del usuario
    String cedula = "", nombre = "", email = "", rol = "", telefono = "", area = "", estado = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
            "unsp1ogkp7qbzhgm", 
            "ZXCRqDEJJIyGydtVjg3G"
        );
        
        String sql = "SELECT * FROM usuarios WHERE id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, usuarioId);
        ResultSet rs = pstmt.executeQuery();
        
        if (rs.next()) {
            cedula = rs.getString("cedula");
            nombre = rs.getString("nombre");
            email = rs.getString("email");
            rol = rs.getString("rol");
            telefono = rs.getString("telefono");
            area = rs.getString("area_conocimiento");
            estado = rs.getString("estado");
        } else {
            response.sendRedirect("gestionUsuarios.jsp?error=usuario_no_encontrado");
            return;
        }
        conn.close();
    } catch (Exception e) {
        mensaje = "Error al cargar usuario: " + e.getMessage();
    }

    // Procesar actualización
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nuevoNombre = request.getParameter("nombre");
        String nuevoEmail = request.getParameter("email");
        String nuevoRol = request.getParameter("rol");
        String nuevoTelefono = request.getParameter("telefono");
        String nuevaArea = request.getParameter("area");
        String nuevoEstado = request.getParameter("estado");
        String nuevaPassword = request.getParameter("password");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q",  
                "bffswfi9tjiywn5lfs3q", 
                "ZXCRqDEJJIyGydtVjg3G"
            );
            
            String sql;
            PreparedStatement pstmt;
            
            if (nuevaPassword != null && !nuevaPassword.trim().isEmpty()) {
                // Actualizar con nueva contraseña
                sql = "UPDATE usuarios SET nombre = ?, email = ?, rol = ?, telefono = ?, area_conocimiento = ?, estado = ?, password = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, nuevoNombre);
                pstmt.setString(2, nuevoEmail);
                pstmt.setString(3, nuevoRol);
                pstmt.setString(4, nuevoTelefono);
                pstmt.setString(5, nuevaArea);
                pstmt.setString(6, nuevoEstado);
                pstmt.setString(7, nuevaPassword);
                pstmt.setString(8, usuarioId);
            } else {
                // Actualizar sin cambiar contraseña
                sql = "UPDATE usuarios SET nombre = ?, email = ?, rol = ?, telefono = ?, area_conocimiento = ?, estado = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, nuevoNombre);
                pstmt.setString(2, nuevoEmail);
                pstmt.setString(3, nuevoRol);
                pstmt.setString(4, nuevoTelefono);
                pstmt.setString(5, nuevaArea);
                pstmt.setString(6, nuevoEstado);
                pstmt.setString(7, usuarioId);
            }
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                response.sendRedirect("gestionUsuarios.jsp?success=usuario_actualizado");
                return;
            } else {
                mensaje = "Error: No se pudo actualizar el usuario";
            }
            
            conn.close();
        } catch (Exception e) {
            mensaje = "Error al actualizar usuario: " + e.getMessage();
        }
    }
    %>

    <div class="main-content">
        <div class="form-container">
            <h2 style="text-align: center; color: var(--uts-red); margin-bottom: 30px;">✏️ Editar Usuario</h2>
            
            <% if (!mensaje.isEmpty()) { %>
                <div class="alert alert-error"><%= mensaje %></div>
            <% } %>
            
            <form method="POST" action="editarUsuario.jsp?id=<%= usuarioId %>">
                <div class="form-group">
                    <label for="cedula">C&#233;dula:</label>
                    <input type="text" class="form-control" id="cedula" value="<%= cedula %>" readonly>
                    <small style="color: #666;">La c&#233;dula no se puede modificar</small>
                </div>
                
                <div class="form-group">
                    <label for="nombre">Nombre Completo:</label>
                    <input type="text" class="form-control" id="nombre" name="nombre" value="<%= nombre %>" required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input type="email" class="form-control" id="email" name="email" value="<%= email %>" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Nueva Contrase&#241;a (opcional):</label>
                    <input type="password" class="form-control" id="password" name="password" placeholder="Dejar vac&#237;o para mantener la actual">
                </div>
                
                <div class="form-group">
                    <label for="rol">Rol:</label>
                    <select class="form-control" id="rol" name="rol" required>
                        <option value="estudiante" <%= "estudiante".equals(rol) ? "selected" : "" %>>Estudiante</option>
                        <option value="director" <%= "director".equals(rol) ? "selected" : "" %>>Director</option>
                        <option value="evaluador" <%= "evaluador".equals(rol) ? "selected" : "" %>>Evaluador</option>
                        <option value="coordinacion" <%= "coordinacion".equals(rol) ? "selected" : "" %>>Coordinaci&#243;n</option>
                        <option value="admin" <%= "admin".equals(rol) ? "selected" : "" %>>Administrador</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="telefono">Tel&#233;fono:</label>
                    <input type="text" class="form-control" id="telefono" name="telefono" value="<%= telefono != null ? telefono : "" %>">
                </div>
                
                <div class="form-group">
                    <label for="area">&#193;rea de Conocimiento:</label>
                    <input type="text" class="form-control" id="area" name="area" value="<%= area != null ? area : "" %>">
                </div>
                
                <div class="form-group">
                    <label for="estado">Estado:</label>
                    <select class="form-control" id="estado" name="estado" required>
                        <option value="activo" <%= "activo".equals(estado) ? "selected" : "" %>>Activo</option>
                        <option value="inactivo" <%= "inactivo".equals(estado) ? "selected" : "" %>>Inactivo</option>
                    </select>
                </div>
                
                <div style="text-align: center; margin-top: 30px;">
                    <button type="submit" class="btn btn-success">💾 Guardar Cambios</button>
                    <a href="gestionUsuarios.jsp" class="btn btn-uts">↩️ Cancelar</a>
                </div>
            </form>
        </div>
    </div>

    <%@ include file="../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>