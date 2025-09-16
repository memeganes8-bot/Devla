<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  Integer userId = (Integer) session.getAttribute("userId");
  String role = (String) session.getAttribute("role");

  if (userId == null || role == null || !"admin".equalsIgnoreCase(role)) {
    response.sendRedirect("login.jsp");
    return;
  }

  String action = request.getParameter("action");
  String msg = "";

  try (Connection conn = getConnection()) {
    // Eliminar usuario
    if ("delete".equals(action)) {
      int id = Integer.parseInt(request.getParameter("id"));
      try (PreparedStatement ps = conn.prepareStatement("DELETE FROM usuarios WHERE id_usuario=?")) {
        ps.setInt(1, id);
        ps.executeUpdate();
        msg = "✅ Usuario eliminado correctamente.";
      }
    }

    // Editar usuario
    if ("edit".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
      int id = Integer.parseInt(request.getParameter("id"));
      String nombre = request.getParameter("nombre");
      String apellido = request.getParameter("apellido");
      String email = request.getParameter("email");
      String telefono = request.getParameter("telefono");
      String direccion = request.getParameter("direccion");
      int rolId = Integer.parseInt(request.getParameter("id_rol"));

      try (PreparedStatement ps = conn.prepareStatement(
        "UPDATE usuarios SET nombre=?, apellido=?, email=?, telefono=?, direccion=?, id_rol=? WHERE id_usuario=?")) {
        ps.setString(1, nombre);
        ps.setString(2, apellido);
        ps.setString(3, email);
        ps.setString(4, telefono);
        ps.setString(5, direccion);
        ps.setInt(6, rolId);
        ps.setInt(7, id);
        ps.executeUpdate();
        msg = "✅ Usuario actualizado correctamente.";
      }
    }

  } catch (Exception e) {
    msg = "❌ Error: " + e.getMessage();
  }

  // Traer todos los usuarios
  List<Map<String, Object>> usuarios = new ArrayList<>();
  try (Connection conn = getConnection();
       Statement st = conn.createStatement();
       ResultSet rs = st.executeQuery("SELECT u.id_usuario, u.nombre, u.apellido, u.email, u.telefono, u.direccion, r.nombre_rol FROM usuarios u JOIN roles r ON u.id_rol=r.id_rol")) {
    while (rs.next()) {
      Map<String, Object> row = new HashMap<>();
      row.put("id_usuario", rs.getInt("id_usuario"));
      row.put("nombre", rs.getString("nombre"));
      row.put("apellido", rs.getString("apellido"));
      row.put("email", rs.getString("email"));
      row.put("telefono", rs.getString("telefono"));
      row.put("direccion", rs.getString("direccion"));
      row.put("rol", rs.getString("nombre_rol"));
      usuarios.add(row);
    }
  } catch (Exception e) {
    msg = "❌ Error cargando usuarios: " + e.getMessage();
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Gestión de Usuarios</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
  <div class="card shadow-sm">
    <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
      <h4 class="mb-0">👥 Gestión de Usuarios</h4>
      <a href="dashboardAdmin.jsp" class="btn btn-outline-light btn-sm">← Volver</a>
    </div>
    <div class="card-body">
      <% if (!msg.isEmpty()) { %>
        <div class="alert <%= msg.startsWith("✅") ? "alert-success" : "alert-danger" %>">
          <%= msg %>
        </div>
      <% } %>

      <div class="table-responsive">
        <table class="table table-hover align-middle">
          <thead class="table-dark">
            <tr>
              <th>ID</th>
              <th>Nombre</th>
              <th>Apellido</th>
              <th>Email</th>
              <th>Teléfono</th>
              <th>Dirección</th>
              <th>Rol</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
          <%
            for (Map<String,Object> u : usuarios) {
          %>
            <tr>
              <td><%= u.get("id_usuario") %></td>
              <td><%= u.get("nombre") %></td>
              <td><%= u.get("apellido") %></td>
              <td><%= u.get("email") %></td>
              <td><%= u.get("telefono") %></td>
              <td><%= u.get("direccion") %></td>
              <td><span class="badge bg-info text-dark"><%= u.get("rol") %></span></td>
              <td>
                <a class="btn btn-sm btn-warning" href="editUsuario.jsp?id=<%= u.get("id_usuario") %>">✏️ Editar</a>
                <a class="btn btn-sm btn-danger" href="adminUsuarios.jsp?action=delete&id=<%= u.get("id_usuario") %>" onclick="return confirm('¿Eliminar este usuario?')">🗑 Eliminar</a>
              </td>
            </tr>
          <%
            }
          %>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>
</body>
</html>
