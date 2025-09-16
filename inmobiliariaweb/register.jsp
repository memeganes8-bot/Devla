<%@ include file="includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String msg = "";
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String nombre = request.getParameter("nombre");
    String apellido = request.getParameter("apellido");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String telefono = request.getParameter("telefono");
    String direccion = request.getParameter("direccion");
    String rol = request.getParameter("rol"); // 'cliente' o 'inmobiliaria'

    if (nombre==null||email==null||password==null || nombre.isEmpty()||email.isEmpty()||password.isEmpty()) {
      msg = "Completa los campos obligatorios.";
    } else {
      try (Connection conn = getConnection()) {
        // Buscar id_rol en la tabla roles
        int idRol = 0; // valor por defecto
        try (PreparedStatement pr = conn.prepareStatement("SELECT id_rol FROM roles WHERE nombre_rol=? LIMIT 1")) {
          pr.setString(1, rol != null ? rol : "cliente");
          try (ResultSet rs = pr.executeQuery()) {
            if (rs.next()) {
              idRol = rs.getInt("id_rol");
            } else {
              idRol = 3; // fallback a cliente si no existe
            }
          }
        }

        // Insertar usuario
        try (PreparedStatement ps = conn.prepareStatement(
             "INSERT INTO usuarios (nombre, apellido, email, password, telefono, direccion, id_rol) VALUES (?,?,?,?,?,?,?)")) {
          ps.setString(1, nombre);
          ps.setString(2, apellido);
          ps.setString(3, email);
          ps.setString(4, sha256(password)); // guardamos hash
          ps.setString(5, telefono);
          ps.setString(6, direccion);
          ps.setInt(7, idRol);
          ps.executeUpdate();
          msg = "Registro exitoso. Ya puedes iniciar sesión.";
        }
      } catch (SQLException e) {
        if (e.getMessage().toLowerCase().contains("duplicate")) {
          msg = "El correo ya está registrado.";
        } else {
          msg = "Error al registrar: " + e.getMessage();
        }
      }
    }
  }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Registro</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-4">
  <div class="row justify-content-center">
    <div class="col-md-6">
      <div class="card p-4">
        <h3>Registro</h3>
        <div class="text-success"><%= msg %></div>
        <form method="post" action="register.jsp">
          <input class="form-control mb-2" name="nombre" placeholder="Nombre" required>
          <input class="form-control mb-2" name="apellido" placeholder="Apellido">
          <input class="form-control mb-2" name="email" placeholder="Email" type="email" required>
          <input class="form-control mb-2" name="password" placeholder="Contraseña" type="password" required>
          <input class="form-control mb-2" name="telefono" placeholder="Teléfono">
          <textarea class="form-control mb-2" name="direccion" placeholder="Dirección"></textarea>
          <label>Tipo de cuenta</label>
          <select class="form-control mb-3" name="rol">
            <option value="cliente">Cliente</option>
            <option value="inmobiliaria">Inmobiliaria</option>
          </select>
          <button class="btn btn-primary w-100" type="submit">Registrar</button>
        </form>
        <hr>
        <p>¿Ya tienes cuenta? <a href="login.jsp">Inicia sesión</a></p>
      </div>
    </div>
  </div>
</div>
</body>
</html>
