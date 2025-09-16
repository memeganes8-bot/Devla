<%@ include file="includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
  // --- Proteger: solo usuarios logueados ---
  Integer userId = (Integer) session.getAttribute("userId");
  if (userId == null) { 
    response.sendRedirect("login.jsp"); 
    return; 
  }

  String propiedadIdParam = request.getParameter("propiedad_id");
  String msg = "";
  String alertClass = "success";

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    int propiedad_id = Integer.parseInt(request.getParameter("propiedad_id"));
    String fecha = request.getParameter("fecha"); // formato esperado: yyyy-MM-ddTHH:mm
    String mensaje = request.getParameter("mensaje");

    // convertir a formato DATETIME de MySQL
    if (fecha != null && fecha.contains("T")) fecha = fecha.replace('T',' ') + ":00";

    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(
           "INSERT INTO citas (cliente_id, propiedad_id, fecha, estado, mensaje, creado_en) " +
           "VALUES (?,?,?,?,?,NOW())")) {
      ps.setInt(1, userId);
      ps.setInt(2, propiedad_id);
      ps.setString(3, fecha);
      ps.setString(4, "pendiente");
      ps.setString(5, mensaje);
      ps.executeUpdate();
      msg = "✅ Cita solicitada correctamente.";
      alertClass = "success";
    } catch (Exception e) { 
      msg = "❌ Error: " + e.getMessage(); 
      alertClass = "danger";
    }
  }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Solicitar cita</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container">
    <a class="navbar-brand" href="index.jsp">🏠 MiInmobiliaria</a>
    <div>
      <a class="btn btn-outline-light me-2" href="propiedades.jsp">Propiedades</a>
      <% if (session.getAttribute("userId")!=null) { %>
        <a class="btn btn-warning" href="logout.jsp">Salir</a>
      <% } else { %>
        <a class="btn btn-light" href="login.jsp">Entrar</a>
      <% } %>
    </div>
  </div>
</nav>

<div class="container mt-4">
  <a href="propiedades.jsp" class="btn btn-link">← Volver</a>

  <div class="card shadow-sm p-4">
    <h3 class="mb-3">Solicitar cita</h3>

    <% if (!msg.isEmpty()) { %>
      <div class="alert alert-<%= alertClass %>"><%= msg %></div>
    <% } %>

    <form method="post" action="solicitarCita.jsp">
      <input type="hidden" name="propiedad_id" value="<%= (propiedadIdParam!=null?propiedadIdParam:"") %>">

      <div class="mb-3">
        <label class="form-label">Fecha y hora</label>
        <input class="form-control" type="datetime-local" name="fecha" required>
      </div>

      <div class="mb-3">
        <label class="form-label">Mensaje</label>
        <textarea class="form-control" name="mensaje" rows="3" placeholder="Ej: Estoy interesado en visitar la propiedad..."></textarea>
      </div>

      <button class="btn btn-primary w-100" type="submit">📅 Solicitar cita</button>
    </form>
  </div>
</div>

<footer class="bg-dark text-light text-center py-3 mt-auto fixed-bottom">
  <div class="container">
    <p>© 2025 MiInmobiliaria - Todos los derechos reservados</p>
  </div>
</footer>

</body>
</html>
