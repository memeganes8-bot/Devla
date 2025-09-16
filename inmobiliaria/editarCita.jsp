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

  String idParam = request.getParameter("id");
  if (idParam == null) { response.sendRedirect("adminCitas.jsp"); return; }
  int idCita = Integer.parseInt(idParam);

  String msg = "";
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String fecha = request.getParameter("fecha");
    String hora = request.getParameter("hora");
    String id_usuario = request.getParameter("id_usuario");
    String id_propiedad = request.getParameter("id_propiedad");
    String estado = request.getParameter("estado");

    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement("UPDATE citas SET fecha=?, hora=?, id_usuario=?, id_propiedad=?, estado=? WHERE id_cita=?")) {
      ps.setString(1, fecha);
      ps.setString(2, hora);
      ps.setInt(3, Integer.parseInt(id_usuario));
      ps.setInt(4, Integer.parseInt(id_propiedad));
      ps.setString(5, estado);
      ps.setInt(6, idCita);
      ps.executeUpdate();
      msg = "✅ Cita actualizada.";
    } catch (Exception e) {
      msg = "❌ Error: " + e.getMessage();
    }
  }

  String fecha="", hora="", estado="Pendiente"; 
  int id_usuario=0, id_propiedad=0;
  try (Connection conn = getConnection();
       PreparedStatement ps = conn.prepareStatement("SELECT * FROM citas WHERE id_cita=?")) {
    ps.setInt(1, idCita);
    try (ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        fecha = rs.getString("fecha");
        hora = rs.getString("hora");
        id_usuario = rs.getInt("id_usuario");
        id_propiedad = rs.getInt("id_propiedad");
        estado = rs.getString("estado");
      }
    }
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Editar Cita</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-4">
  <h3>✏️ Editar Cita</h3>
  <div class="text-success"><%= msg %></div>
  <form method="post" action="editarCita.jsp?id=<%= idCita %>">
    <input class="form-control mb-2" type="date" name="fecha" value="<%= fecha %>" required>
    <input class="form-control mb-2" type="time" name="hora" value="<%= hora %>" required>
    <input class="form-control mb-2" name="id_usuario" value="<%= id_usuario %>" required>
    <input class="form-control mb-2" name="id_propiedad" value="<%= id_propiedad %>" required>
    <select name="estado" class="form-control mb-3">
      <option value="Pendiente" <%= ("Pendiente".equals(estado)?"selected":"") %>>Pendiente</option>
      <option value="Confirmada" <%= ("Confirmada".equals(estado)?"selected":"") %>>Confirmada</option>
      <option value="Cancelada" <%= ("Cancelada".equals(estado)?"selected":"") %>>Cancelada</option>
    </select>
    <button class="btn btn-primary" type="submit">Actualizar</button>
    <a href="adminCitas.jsp" class="btn btn-secondary">← Volver</a>
  </form>
</div>
</body>
</html>
