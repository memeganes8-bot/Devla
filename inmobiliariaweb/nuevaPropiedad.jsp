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

  String msg = "";
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String titulo = request.getParameter("titulo");
    String descripcion = request.getParameter("descripcion");
    String precio = request.getParameter("precio");
    String ubicacion = request.getParameter("ubicacion");
    String tipo = request.getParameter("tipo");
    String fotos = request.getParameter("fotos");
    String disponible = request.getParameter("disponible");

    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(
           "INSERT INTO propiedades (titulo, descripcion, precio, ubicacion, tipo, fotos, id_usuario, disponible, creado_en) VALUES (?,?,?,?,?,?,?, ?, NOW())")) {
      ps.setString(1, titulo);
      ps.setString(2, descripcion);
      ps.setDouble(3, Double.parseDouble(precio));
      ps.setString(4, ubicacion);
      ps.setString(5, tipo);
      ps.setString(6, fotos);
      ps.setInt(7, userId); // el admin que creó
      ps.setInt(8, "1".equals(disponible) ? 1 : 0);
      ps.executeUpdate();
      msg = "✅ Propiedad agregada correctamente.";
    } catch (Exception e) {
      msg = "❌ Error: " + e.getMessage();
    }
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Nueva Propiedad</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-4">
  <h3>➕ Nueva Propiedad</h3>
  <div class="text-success"><%= msg %></div>
  <form method="post" action="nuevaPropiedad.jsp">
    <input class="form-control mb-2" name="titulo" placeholder="Título" required>
    <textarea class="form-control mb-2" name="descripcion" placeholder="Descripción"></textarea>
    <input class="form-control mb-2" name="precio" placeholder="Precio" type="number" step="0.01" required>
    <input class="form-control mb-2" name="ubicacion" placeholder="Ubicación" required>
    <input class="form-control mb-2" name="tipo" placeholder="Tipo (ej: Casa, Lote, Apartamento)">
    <input class="form-control mb-2" name="fotos" placeholder="URL de fotos (separadas por coma)">
    <label class="form-label">Disponible:</label>
    <select name="disponible" class="form-control mb-3">
      <option value="1">Sí</option>
      <option value="0">No</option>
    </select>
    <button class="btn btn-primary" type="submit">Guardar</button>
    <a href="adminPropiedades.jsp" class="btn btn-secondary">← Volver</a>
  </form>
</div>
</body>
</html>
