<%@ page import="java.sql.*" %>
<%@ include file="includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  Integer userId = (Integer) session.getAttribute("userId");
  String role = (String) session.getAttribute("role");

  if (userId == null || role == null || !"admin".equalsIgnoreCase(role)) {
    response.sendRedirect("login.jsp");
    return;
  }

  int id = Integer.parseInt(request.getParameter("id"));
  String nombre="", apellido="", email="", telefono="", direccion="";
  int idRol=0;

  try (Connection conn = getConnection();
       PreparedStatement ps = conn.prepareStatement("SELECT * FROM usuarios WHERE id_usuario=?")) {
    ps.setInt(1, id);
    try (ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        nombre = rs.getString("nombre");
        apellido = rs.getString("apellido");
        email = rs.getString("email");
        telefono = rs.getString("telefono");
        direccion = rs.getString("direccion");
        idRol = rs.getInt("id_rol");
      }
    }
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Editar Usuario</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-4">
  <a href="adminUsuarios.jsp" class="btn btn-secondary mb-3">← Volver</a>
  <h2>Editar Usuario</h2>
  <form method="post" action="adminUsuarios.jsp?action=edit">
    <input type="hidden" name="id" value="<%= id %>">
    <div class="mb-2"><input class="form-control" type="text" name="nombre" value="<%= nombre %>" required></div>
    <div class="mb-2"><input class="form-control" type="text" name="apellido" value="<%= apellido %>" required></div>
    <div class="mb-2"><input class="form-control" type="email" name="email" value="<%= email %>" required></div>
    <div class="mb-2"><input class="form-control" type="text" name="telefono" value="<%= telefono %>"></div>
    <div class="mb-2"><input class="form-control" type="text" name="direccion" value="<%= direccion %>"></div>
    <div class="mb-2">
      <label>Rol</label>
      <select class="form-control" name="id_rol">
        <option value="1" <%= (idRol==1?"selected":"") %>>Admin</option>
        <option value="3" <%= (idRol==3?"selected":"") %>>Cliente</option>
        <option value="4" <%= (idRol==4?"selected":"") %>>Inmobiliaria</option>
      </select>
    </div>
    <button class="btn btn-primary">Guardar cambios</button>
  </form>
</div>
</body>
</html>
