<%@ include file="includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String error = "";
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    if (email == null || password == null || email.isEmpty() || password.isEmpty()) {
      error = "Completa los campos.";
    } else {
      try (Connection conn = getConnection();
           PreparedStatement ps = conn.prepareStatement(
             "SELECT u.id_usuario, u.nombre, u.password, r.nombre_rol " +
             "FROM usuarios u JOIN roles r ON u.id_rol=r.id_rol " +
             "WHERE u.email = ? LIMIT 1")) {

        ps.setString(1, email);

        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) {
            String storedHash = rs.getString("password");
            if (storedHash.equals(sha256(password))) {
              // Guardar datos en sesión
              session.setAttribute("userId", rs.getInt("id_usuario"));
              session.setAttribute("username", rs.getString("nombre"));
              session.setAttribute("role", rs.getString("nombre_rol"));

              // Redirección según rol
              String rol = rs.getString("nombre_rol");
              if ("admin".equalsIgnoreCase(rol)) {
                response.sendRedirect("dashboardAdmin.jsp"); // dashboard del admin
              } else if ("inmobiliaria".equalsIgnoreCase(rol)) {
                response.sendRedirect("dashboardInmo.jsp"); // Crea este archivo
              } else if ("cliente".equalsIgnoreCase(rol)) {
                response.sendRedirect("propiedades.jsp");
              } else {
                response.sendRedirect("index.jsp");
              }

              return; // importante detener la ejecución aquí
            } else {
              error = "Email o contraseña incorrectos.";
            }
          } else {
            error = "Email o contraseña incorrectos.";
          }
        }
      } catch (SQLException e) {
        error = "Error BD: " + e.getMessage();
      }
    }
  }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Login</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-4">
  <div class="row justify-content-center">
    <div class="col-md-5">
      <div class="card p-4">
        <h3>Iniciar sesión</h3>
        <div class="text-danger"><%= error %></div>
        <form method="post" action="login.jsp">
          <input class="form-control mb-2" name="email" placeholder="Email" type="email" required>
          <input class="form-control mb-2" name="password" placeholder="Contraseña" type="password" required>
          <button class="btn btn-primary w-100" type="submit">Entrar</button>
        </form>
        <hr>
        <p>¿No tienes cuenta? <a href="register.jsp">Regístrate</a></p>
      </div>
    </div>
  </div>
</div>
</body>
</html>
