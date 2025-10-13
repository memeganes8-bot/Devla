<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrar Usuario - UTS</title>
    <link rel="stylesheet" href="../../css/styles.css">
</head>
<body>
    <%@ include file="../../../WEB-INF/jspf/header.jspf" %>

    <div class="main-content">
        <%
        // Procesar registro de usuario
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String cedula = request.getParameter("cedula");
            String nombre = request.getParameter("nombre");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String rol = request.getParameter("rol");
            String telefono = request.getParameter("telefono");
            String area = request.getParameter("area");
            
            Connection conn = null;
            PreparedStatement pstmt = null;
            PreparedStatement checkStmt = null;
            ResultSet rs = null;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(
                    "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
                    "unsp1ogkp7qbzhgm", 
                    "ZXCRqDEJJIyGydtVjg3G"
                );
                
                // Verificar si el email o cédula ya existen
                String checkSql = "SELECT id FROM usuarios WHERE email = ? OR cedula = ?";
                checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setString(1, email);
                checkStmt.setString(2, cedula);
                rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    out.println("<div class='alert alert-error'>❌ Error: El email o cédula ya existen en el sistema</div>");
                } else {
                    // Insertar nuevo usuario
                    String sql = "INSERT INTO usuarios (cedula, nombre, email, password, rol, telefono, area_conocimiento) VALUES (?, ?, ?, ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, cedula);
                    pstmt.setString(2, nombre);
                    pstmt.setString(3, email);
                    pstmt.setString(4, password);
                    pstmt.setString(5, rol);
                    pstmt.setString(6, telefono);
                    pstmt.setString(7, area);
                    
                    int result = pstmt.executeUpdate();
                    
                    if (result > 0) {
                        response.sendRedirect("gestionUsuarios.jsp?success=usuario_creado");
                        return;
                    }
                }
                
            } catch (Exception e) {
                out.println("<div class='alert alert-error'>❌ Error: " + e.getMessage() + "</div>");
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception e) {}
                try { if (checkStmt != null) checkStmt.close(); } catch (Exception e) {}
                try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
                try { if (conn != null) conn.close(); } catch (Exception e) {}
            }
        }
        %>

        <div class="form-container">
            <h2 style="text-align: center; color: var(--uts-red); margin-bottom: 30px;">➕ Registrar Nuevo Usuario</h2>
            
            <form method="POST" action="registrarUsuario.jsp">
                <div class="form-group">
                    <label for="cedula">C&#233;dula:</label>
                    <input type="text" class="form-control" id="cedula" name="cedula" required>
                </div>
                
                <div class="form-group">
                    <label for="nombre">Nombre Completo:</label>
                    <input type="text" class="form-control" id="nombre" name="nombre" required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input type="email" class="form-control" id="email" name="email" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Contrase&#241;a:</label>
                    <input type="password" class="form-control" id="password" name="password" required>
                </div>
                
                <div class="form-group">
                    <label for="rol">Rol:</label>
                    <select class="form-control" id="rol" name="rol" required>
                        <option value="">-- Seleccione Rol --</option>
                        <option value="estudiante">Estudiante</option>
                        <option value="director">Director</option>
                        <option value="evaluador">Evaluador</option>
                        <option value="coordinacion">Coordinaci&#243;n</option>
                        <option value="admin">Administrador</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="telefono">Tel&#233;fono:</label>
                    <input type="text" class="form-control" id="telefono" name="telefono">
                </div>
                
                <div class="form-group">
                    <label for="area">&#193;rea de Conocimiento:</label>
                    <input type="text" class="form-control" id="area" name="area">
                </div>
                
                <div style="text-align: center; margin-top: 30px;">
                    <button type="submit" class="btn btn-success">💾 Registrar Usuario</button>
                    <a href="gestionUsuarios.jsp" class="btn btn-uts">↩️ Cancelar</a>
                </div>
            </form>
        </div>
    </div>

    <%@ include file="../../../WEB-INF/jspf/footer.jspf" %>
</body>
</html>