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

  // Eliminar propiedad si llega ?eliminar
  String eliminarId = request.getParameter("eliminar");
  if (eliminarId != null) {
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement("DELETE FROM propiedades WHERE id_propiedad=?")) {
      ps.setInt(1, Integer.parseInt(eliminarId));
      ps.executeUpdate();
    } catch (Exception e) {
      out.println("Error eliminando: " + e.getMessage());
    }
  }

  // Cargar propiedades
  List<Map<String,Object>> propiedades = new ArrayList<>();
  try (Connection conn = getConnection();
       Statement st = conn.createStatement();
       ResultSet rs = st.executeQuery("SELECT * FROM propiedades ORDER BY id_propiedad DESC")) {
    while (rs.next()) {
      Map<String,Object> row = new HashMap<>();
      row.put("id_propiedad", rs.getInt("id_propiedad"));
      row.put("titulo", rs.getString("titulo"));
      row.put("descripcion", rs.getString("descripcion"));
      row.put("precio", rs.getDouble("precio"));
      row.put("ubicacion", rs.getString("ubicacion")); // CORREGIDO
      row.put("tipo", rs.getString("tipo"));
      row.put("fotos", rs.getString("fotos"));
      row.put("disponible", rs.getInt("disponible"));
      propiedades.add(row);
    }
  } catch (Exception e) {
    out.println("Error cargando propiedades: " + e.getMessage());
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Gestión de Propiedades</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-4">
  <h2>🏠 Gestión de Propiedades</h2>
  <a href="nuevaPropiedad.jsp" class="btn btn-primary mb-3">➕ Nueva Propiedad</a>
  <table class="table table-bordered">
    <thead>
      <tr>
        <th>ID</th>
        <th>Título</th>
        <th>Descripción</th>
        <th>Precio</th>
        <th>Ubicación</th>
        <th>Tipo</th>
        <th>Disponible</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody>
      <%
        for (Map<String,Object> p : propiedades) {
      %>
      <tr>
        <td><%= p.get("id_propiedad") %></td>
        <td><%= p.get("titulo") %></td>
        <td><%= p.get("descripcion") %></td>
        <td>$<%= p.get("precio") %></td>
        <td><%= p.get("ubicacion") %></td>
        <td><%= p.get("tipo") %></td>
        <td><%= ((Integer)p.get("disponible") == 1 ? "Sí" : "No") %></td>
        <td>
          <a href="editarPropiedad.jsp?id=<%= p.get("id_propiedad") %>" class="btn btn-sm btn-warning">Editar</a>
          <a href="adminPropiedades.jsp?eliminar=<%= p.get("id_propiedad") %>" class="btn btn-sm btn-danger" onclick="return confirm('¿Eliminar esta propiedad?')">Eliminar</a>
        </td>
      </tr>
      <% } %>
    </tbody>
  </table>
  <a href="dashboardAdmin.jsp" class="btn btn-secondary">← Volver</a>
</div>
</body>
</html>
