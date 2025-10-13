<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
// Verificar autenticación y rol de admin
String usuarioRol = (String) session.getAttribute("usuario_rol");
if (usuarioRol == null || !"admin".equals(usuarioRol)) {
    response.sendRedirect("../../login.jsp");
    return;
}

String usuarioId = request.getParameter("id");
String mensaje = "";

if (usuarioId != null) {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
            "unsp1ogkp7qbzhgm", 
            "ZXCRqDEJJIyGydtVjg3G"
        );
        
        // Verificar si el usuario tiene proyectos asociados
        String checkSql = "SELECT COUNT(*) as count FROM proyectos WHERE estudiante_id = ? OR director_id = ? OR evaluador_id = ?";
        PreparedStatement checkStmt = conn.prepareStatement(checkSql);
        checkStmt.setString(1, usuarioId);
        checkStmt.setString(2, usuarioId);
        checkStmt.setString(3, usuarioId);
        ResultSet rs = checkStmt.executeQuery();
        
        if (rs.next() && rs.getInt("count") > 0) {
            // Si tiene proyectos, marcar como inactivo en lugar de eliminar
            String updateSql = "UPDATE usuarios SET estado = 'inactivo' WHERE id = ?";
            PreparedStatement updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setString(1, usuarioId);
            updateStmt.executeUpdate();
            mensaje = "usuario_inactivado";
        } else {
            // Si no tiene proyectos, eliminar
            String deleteSql = "DELETE FROM usuarios WHERE id = ?";
            PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
            deleteStmt.setString(1, usuarioId);
            deleteStmt.executeUpdate();
            mensaje = "usuario_eliminado";
        }
        
        conn.close();
    } catch (Exception e) {
        mensaje = "error: " + e.getMessage();
    }
}

// Redirigir con mensaje apropiado
if (mensaje.contains("error")) {
    response.sendRedirect("gestionUsuarios.jsp?error=" + mensaje);
} else {
    response.sendRedirect("gestionUsuarios.jsp?success=" + mensaje);
}
%>