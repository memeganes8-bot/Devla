<%@ include file="../includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
  if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("rol"))) {
    response.sendRedirect("../login.jsp");
    return;
  }

  java.util.List<java.util.Map<String,Object>> usuarios = new java.util.ArrayList<>();
  try (Connection conn = getConnection();
       PreparedStatement ps = conn.prepareStatement(
         "SELECT u.id_usuario, u.nombre, u.apellido, u.email, r.nombre_rol " +
         "FROM usuarios u LEFT JOIN roles r ON u.id_rol = r.id_rol")) {
    try (ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        java.util.Map<String,Object> u = new java.util.HashMap<>();
        u.put("id", rs.getInt("id_usuario"));
        u.put("nombre", rs.getString("nombre"));
        u.put("apellido", rs.getString("apellido"));
        u.put("email", rs.getString("email"));
        u.put("rol", rs.getString("nombre_rol"));
        usuarios.add(u);
      }
    }
  } catch(Exception e) { out.println("Error: "+e.getMessage()); }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Usuarios</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-4">
  <h2>Usuarios registrados</h2>
  <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Volver al Dashboard</a>
  <table class="table table-striped">
    <thead><tr><th>ID</th><th>Nombre</th><th>Email</th><th>Rol</th><th>Acciones</th></tr></thead>
    <tbody>
    <% for (java.util.Map<String,Object> u : usuarios) { %>
      <tr>
        <td><%= u.get("id") %></td>
        <td><%= u.get("nombre") %> <%= u.get("apellido") %></td>
        <td><%= u.get("email") %></td>
        <td><%= u.get("rol") %></td>
        <td>
          <a href="editarUsuario.jsp?id=<%= u.get("id") %>" class="btn btn-sm btn-primary">Editar</a>
          <a href="eliminarUsuario.jsp?id=<%= u.get("id") %>" class="btn btn-sm btn-danger"
             onclick="return confirm('¿Seguro que deseas eliminar este usuario?')">Eliminar</a>
        </td>
      </tr>
    <% } %>
    </tbody>
  </table>
</div>
</body>
</html>
