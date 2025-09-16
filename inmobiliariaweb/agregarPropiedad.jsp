<%@ include file="includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
  // Proteger: solo inmobiliaria o admin
  String role = (String) session.getAttribute("role");
  if (role == null || !(role.equals("inmobiliaria") || role.equals("admin"))) {
    response.sendRedirect("login.jsp");
    return;
  }

  String msg = "";
  String editId = request.getParameter("edit");
  boolean isEdit = editId != null && !editId.isEmpty();
  String titulo="", descripcion="", precio="", ubicacion="", tipo="", fotos="";
  if (isEdit) {
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT * FROM propiedades WHERE id_propiedad=?")) {
      ps.setInt(1, Integer.parseInt(editId));
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          titulo = rs.getString("titulo");
          descripcion = rs.getString("descripcion");
          precio = rs.getString("precio");
          ubicacion = rs.getString("ubicacion");
          tipo = rs.getString("tipo");
          fotos = rs.getString("fotos");
        } else {
          if ("admin".equalsIgnoreCase(role)) {
            response.sendRedirect("adminPropiedades.jsp"); return;
          } else {
            response.sendRedirect("listarPropiedades.jsp"); return;
          }
        }
      }
    } catch (Exception e) { out.println("Error: "+e.getMessage()); }
  }

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    titulo = request.getParameter("titulo");
    descripcion = request.getParameter("descripcion");
    precio = request.getParameter("precio");
    ubicacion = request.getParameter("ubicacion");
    tipo = request.getParameter("tipo");
    fotos = request.getParameter("fotos"); // coma-separated URLs
    Integer userId = (Integer) session.getAttribute("userId");

    try (Connection conn = getConnection()) {
      if (isEdit) {
        try (PreparedStatement ps = conn.prepareStatement(
            "UPDATE propiedades SET titulo=?, descripcion=?, precio=?, ubicacion=?, tipo=?, fotos=? WHERE id_propiedad=?")) {
          ps.setString(1, titulo); ps.setString(2, descripcion);
          ps.setBigDecimal(3, new java.math.BigDecimal(precio));
          ps.setString(4, ubicacion); ps.setString(5, tipo); ps.setString(6, fotos);
          ps.setInt(7, Integer.parseInt(editId));
          ps.executeUpdate();
          msg = "Propiedad actualizada.";
        }
      } else {
        try (PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO propiedades (titulo, descripcion, precio, ubicacion, tipo, fotos, id_usuario, disponible) VALUES (?,?,?,?,?,?,?,1)")) {
          ps.setString(1, titulo); ps.setString(2, descripcion);
          ps.setBigDecimal(3, new java.math.BigDecimal(precio));
          ps.setString(4, ubicacion); ps.setString(5, tipo); ps.setString(6, fotos);
          ps.setInt(7, userId);
          ps.executeUpdate();
          msg = "Propiedad agregada.";
        }
      }
    } catch (Exception e) { msg = "Error: "+e.getMessage(); }
  }

  // URL de volver según el rol
  String volverUrl = "adminPropiedades.jsp";
  if ("inmobiliaria".equalsIgnoreCase(role)) {
    volverUrl = "dashboardInmo.jsp"; // panel inmobiliaria
  }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title><%= isEdit ? "Editar" : "Agregar" %> Propiedad</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-4">
  <a href="<%= volverUrl %>" class="btn btn-link">← Volver</a>
  <div class="card p-3">
    <h3><%= isEdit ? "Editar" : "Agregar" %> Propiedad</h3>
    <div class="text-success"><%= msg %></div>
    <form method="post" action="agregarPropiedad.jsp<%= isEdit ? "?edit="+editId : "" %>">
      <input class="form-control mb-2" name="titulo" placeholder="Título" required value="<%= titulo %>">
      <textarea class="form-control mb-2" name="descripcion" placeholder="Descripción"><%= descripcion %></textarea>
      <input class="form-control mb-2" name="precio" placeholder="Precio" required value="<%= precio %>">
      <input class="form-control mb-2" name="ubicacion" placeholder="Ubicación" value="<%= ubicacion %>">
      <select class="form-control mb-2" name="tipo">
        <option value="casa" <%= "casa".equals(tipo)?"selected":"" %>>Casa</option>
        <option value="apartamento" <%= "apartamento".equals(tipo)?"selected":"" %>>Apartamento</option>
        <option value="terreno" <%= "terreno".equals(tipo)?"selected":"" %>>Terreno</option>
        <option value="oficina" <%= "oficina".equals(tipo)?"selected":"" %>>Oficina</option>
      </select>
      <input class="form-control mb-2" name="fotos" placeholder="URLs de fotos separadas por coma" value="<%= fotos %>">
      <button class="btn btn-primary" type="submit"><%= isEdit ? "Actualizar" : "Crear" %></button>
    </form>
  </div>
</div>
</body>
</html>
