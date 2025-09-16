<%@ include file="../includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
  // --- Verificación de sesión y rol (soporta tanto "rol" como "role") ---
  Object rolObj = session.getAttribute("rol");
  if (rolObj == null) rolObj = session.getAttribute("role");
  String rolSesion = rolObj != null ? rolObj.toString() : null;

  if (session.getAttribute("userId") == null || !"admin".equalsIgnoreCase(rolSesion)) {
    response.sendRedirect("../login.jsp");
    return;
  }

  String msg = "";
  String idStr = request.getParameter("id");
  if (idStr == null || idStr.trim().isEmpty()) {
    response.sendRedirect("listarUsuarios.jsp");
    return;
  }
  int idUsuario = Integer.parseInt(idStr);

  // Si llega un POST -> procesar actualización
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String nombre = request.getParameter("nombre");
    String apellido = request.getParameter("apellido");
    String email = request.getParameter("email");
    String telefono = request.getParameter("telefono");
    String direccion = request.getParameter("direccion");
    String idRolStr = request.getParameter("id_rol");
    String nuevaPass = request.getParameter("password"); // opcional, si viene vacío no actualiza

    if (nombre == null || nombre.trim().isEmpty() || email == null || email.trim().isEmpty() || idRolStr == null) {
      msg = "Nombre, email y rol son obligatorios.";
    } else {
      int idRol = Integer.parseInt(idRolStr);
      try (Connection conn = getConnection()) {
        if (nuevaPass != null && !nuevaPass.trim().isEmpty()) {
          // Actualiza con contraseña (hash)
          try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE usuarios SET nombre=?, apellido=?, email=?, password=?, telefono=?, direccion=?, id_rol=? WHERE id_usuario=?")) {
            ps.setString(1, nombre);
            ps.setString(2, apellido);
            ps.setString(3, email);
            ps.setString(4, sha256(nuevaPass));
            ps.setString(5, telefono);
            ps.setString(6, direccion);
            ps.setInt(7, idRol);
            ps.setInt(8, idUsuario);
            ps.executeUpdate();
            msg = "Usuario actualizado (contraseña cambiada).";
          }
        } else {
          // Actualiza sin cambiar contraseña
          try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE usuarios SET nombre=?, apellido=?, email=?, telefono=?, direccion=?, id_rol=? WHERE id_usuario=?")) {
            ps.setString(1, nombre);
            ps.setString(2, apellido);
            ps.setString(3, email);
            ps.setString(4, telefono);
            ps.setString(5, direccion);
            ps.setInt(6, idRol);
            ps.setInt(7, idUsuario);
            ps.executeUpdate();
            msg = "Usuario actualizado.";
          }
        }
      } catch (SQLException e) {
        if (e.getMessage().toLowerCase().contains("duplicate")) {
          msg = "Error: el email ya está registrado por otro usuario.";
        } else {
          msg = "Error al actualizar: " + e.getMessage();
        }
      }
    }
  }

  // --- Cargar datos actualizados del usuario (para mostrar en el formulario) ---
  String nombre = "", apellido = "", email = "", telefono = "", direccion = "";
  int selectedRoleId = 0;
  try (Connection conn = getConnection();
       PreparedStatement ps = conn.prepareStatement(
         "SELECT nombre, apellido, email, telefono, direccion, id_rol FROM usuarios WHERE id_usuario=? LIMIT 1")) {
    ps.setInt(1, idUsuario);
    try (ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        nombre = rs.getString("nombre");
        apellido = rs.getString("apellido");
        email = rs.getString("email");
        telefono = rs.getString("telefono");
        direccion = rs.getString("direccion");
        selectedRoleId = rs.getInt("id_rol");
      } else {
        // si no existe el usuario redirigimos
        response.sendRedirect("listarUsuarios.jsp");
        return;
      }
    }
  } catch (SQLException e) {
    out.println("Error al cargar usuario: " + e.getMessage());
    return;
  }

  // --- Cargar lista de roles para el select ---
  java.util.List<java.util.Map<String,Object>> roles = new java.util.ArrayList<>();
  try (Connection conn = getConnection();
       PreparedStatement ps = conn.prepareStatement("SELECT id_rol, nombre_rol FROM roles ORDER BY id_rol")) {
    try (ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        java.util.Map<String,Object> r = new java.util.HashMap<>();
        r.put("id", rs.getInt("id_rol"));
        r.put("nombre", rs.getString("nombre_rol"));
        roles.add(r);
      }
    }
  } catch (SQLException e) {
    out.println("Error al cargar roles: " + e.getMessage());
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
  <a href="listarUsuarios.jsp" class="btn btn-secondary mb-3">← Volver</a>

  <div class="card p-4">
    <h3>Editar usuario #<%= idUsuario %></h3>
    <div class="text-success mb-2"><%= msg %></div>

    <form method="post" action="editarUsuario.jsp?id=<%= idUsuario %>">
      <div class="row">
        <div class="col-md-6 mb-2">
          <label class="form-label">Nombre</label>
          <input class="form-control" name="nombre" required value="<%= org.apache.commons.lang3.StringEscapeUtils.escapeHtml4(nombre) %>">
        </div>
        <div class="col-md-6 mb-2">
          <label class="form-label">Apellido</label>
          <input class="form-control" name="apellido" value="<%= org.apache.commons.lang3.StringEscapeUtils.escapeHtml4(apellido) %>">
        </div>
      </div>

      <div class="mb-2">
        <label class="form-label">Email</label>
        <input class="form-control" name="email" type="email" required value="<%= org.apache.commons.lang3.StringEscapeUtils.escapeHtml4(email) %>">
      </div>

      <div class="row">
        <div class="col-md-6 mb-2">
          <label class="form-label">Teléfono</label>
          <input class="form-control" name="telefono" value="<%= org.apache.commons.lang3.StringEscapeUtils.escapeHtml4(telefono) %>">
        </div>
        <div class="col-md-6 mb-2">
          <label class="form-label">Rol</label>
          <select class="form-control" name="id_rol" required>
            <% for (java.util.Map<String,Object> r : roles) {
                 int rid = (Integer) r.get("id");
                 String rname = (String) r.get("nombre");
            %>
              <option value="<%= rid %>" <%= (rid == selectedRoleId) ? "selected" : "" %>><%= rname %></option>
            <% } %>
          </select>
        </div>
      </div>

      <div class="mb-2">
        <label class="form-label">Dirección</label>
        <textarea class="form-control" name="direccion"><%= org.apache.commons.lang3.StringEscapeUtils.escapeHtml4(direccion) %></textarea>
      </div>

      <div class="mb-3">
        <label class="form-label">Nueva contraseña (dejar en blanco para no cambiar)</label>
        <input class="form-control" name="password" type="password" placeholder="Nueva contraseña">
      </div>

      <button class="btn btn-primary" type="submit">Guardar cambios</button>
      <a class="btn btn-danger ms-2" href="eliminarUsuario.jsp?id=<%= idUsuario %>"
         onclick="return confirm('¿Eliminar este usuario? Esta acción no se puede deshacer.');">Eliminar usuario</a>
    </form>
  </div>
</div>
</body>
</html>
