<%@ page import="java.sql.*" %>
<%@ include file="includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  Integer userId = (Integer) session.getAttribute("userId");
  String role = (String) session.getAttribute("role");

  // Validación de sesión y rol permitido
  if (userId == null || role == null || 
      !( "admin".equalsIgnoreCase(role) || "inmobiliaria".equalsIgnoreCase(role) )) {
    response.sendRedirect("login.jsp");
    return;
  }

  String idParam = request.getParameter("id");
  if (idParam == null) { 
    if ("admin".equalsIgnoreCase(role)) {
      response.sendRedirect("adminPropiedades.jsp"); 
    } else {
      response.sendRedirect("listarPropiedades.jsp");
    }
    return; 
  }
  int idProp = Integer.parseInt(idParam);

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
           "UPDATE propiedades SET titulo=?, descripcion=?, precio=?, ubicacion=?, tipo=?, fotos=?, disponible=? WHERE id_propiedad=?")) {
      ps.setString(1, titulo);
      ps.setString(2, descripcion);
      ps.setDouble(3, Double.parseDouble(precio));
      ps.setString(4, ubicacion);
      ps.setString(5, tipo);
      ps.setString(6, fotos);
      ps.setInt(7, "1".equals(disponible) ? 1 : 0);
      ps.setInt(8, idProp);
      ps.executeUpdate();
      msg = "✅ Propiedad actualizada correctamente.";
    } catch (Exception e) {
      msg = "❌ Error: " + e.getMessage();
    }
  }

  // Cargar datos actuales de la propiedad
  String titulo="", descripcion="", ubicacion="", tipo="", fotos=""; 
  double precio=0;
  int disponible=1;
  try (Connection conn = getConnection();
       PreparedStatement ps = conn.prepareStatement("SELECT * FROM propiedades WHERE id_propiedad=?")) {
    ps.setInt(1, idProp);
    try (ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        titulo = rs.getString("titulo");
        descripcion = rs.getString("descripcion");
        precio = rs.getDouble("precio");
        ubicacion = rs.getString("ubicacion");
        tipo = rs.getString("tipo");
        fotos = rs.getString("fotos");
        disponible = rs.getInt("disponible");
      }
    }
  }

  // Definir URL de volver según rol
  String volverUrl = "adminPropiedades.jsp";
  if ("inmobiliaria".equalsIgnoreCase(role)) {
      volverUrl = "listarPropiedades.jsp"; 
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Editar Propiedad</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-4">
  <h3>✏️ Editar Propiedad</h3>
  <div class="text-success"><%= msg %></div>
  <form method="post" action="editarPropiedad.jsp?id=<%= idProp %>">
    <input class="form-control mb-2" name="titulo" value="<%= titulo %>" required>
    <textarea class="form-control mb-2" name="descripcion"><%= descripcion %></textarea>
    <input class="form-control mb-2" name="precio" type="number" step="0.01" value="<%= precio %>" required>
    <input class="form-control mb-2" name="ubicacion" value="<%= ubicacion %>" required>
    <input class="form-control mb-2" name="tipo" value="<%= tipo %>">
    <input class="form-control mb-2" name="fotos" value="<%= fotos %>">
    <label class="form-label">Disponible:</label>
    <select name="disponible" class="form-control mb-3">
      <option value="1" <%= (disponible==1?"selected":"") %>>Sí</option>
      <option value="0" <%= (disponible==0?"selected":"") %>>No</option>
    </select>
    <button class="btn btn-primary" type="submit">Actualizar</button>
    <a href="<%= volverUrl %>" class="btn btn-secondary">← Volver</a>
  </form>
</div>
</body>
</html>
