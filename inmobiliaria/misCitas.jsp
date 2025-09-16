<%@ include file="includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>

<%
  // Validar sesión
  Integer userId = (Integer) session.getAttribute("userId");
  String userRole = (String) session.getAttribute("role");

  if (userId == null || userRole == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  List<Map<String,Object>> citas = new ArrayList<>();
  try (Connection conn = getConnection()) {
    String sql = "";

    if ("inmobiliaria".equalsIgnoreCase(userRole)) {
      sql = "SELECT c.id_cita, u.nombre AS cliente, p.titulo AS propiedad, " +
            "c.fecha, c.estado, c.mensaje " +
            "FROM citas c " +
            "JOIN usuarios u ON c.cliente_id = u.id_usuario " +
            "JOIN propiedades p ON c.propiedad_id = p.id_propiedad " +
            "WHERE p.id_usuario = ?";
    } else {
      sql = null;
    }

    if (sql != null) {
      try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        try (ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
            Map<String,Object> row = new HashMap<>();
            row.put("id_cita", rs.getInt("id_cita"));
            row.put("cliente", rs.getString("cliente"));
            row.put("propiedad", rs.getString("propiedad"));
            row.put("fecha", rs.getString("fecha"));
            row.put("estado", rs.getString("estado"));
            row.put("mensaje", rs.getString("mensaje"));
            citas.add(row);
          }
        }
      }
    }
  } catch (Exception e) {
    out.println("Error al cargar citas: " + e.getMessage());
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Mis Citas</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
  <div class="card shadow-sm">
    <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
      <h4 class="mb-0">📅 Mis Citas</h4>
      <a href="dashboardInmo.jsp" class="btn btn-light btn-sm">← Volver al Panel</a>
    </div>
    <div class="card-body">
      <%
        if (citas.isEmpty()) {
      %>
        <div class="alert alert-info text-center">
          No hay citas registradas por ahora.
        </div>
      <%
        } else {
      %>
        <div class="table-responsive">
          <table class="table table-hover align-middle">
            <thead class="table-dark">
              <tr>
                <th>ID</th>
                <th>Cliente</th>
                <th>Propiedad</th>
                <th>Fecha</th>
                <th>Estado</th>
                <th>Mensaje</th>
              </tr>
            </thead>
            <tbody>
              <%
                for (Map<String,Object> c : citas) {
                  String estado = (String)c.get("estado");
                  String badgeClass = "secondary";
                  if ("pendiente".equalsIgnoreCase(estado)) badgeClass = "warning";
                  else if ("confirmada".equalsIgnoreCase(estado)) badgeClass = "success";
                  else if ("cancelada".equalsIgnoreCase(estado)) badgeClass = "danger";
              %>
                <tr>
                  <td><%= c.get("id_cita") %></td>
                  <td><%= c.get("cliente") %></td>
                  <td><%= c.get("propiedad") %></td>
                  <td><%= c.get("fecha") %></td>
                  <td>
                    <span class="badge bg-<%= badgeClass %>">
                      <%= estado %>
                    </span>
                  </td>
                  <td><%= c.get("mensaje") %></td>
                </tr>
              <%
                }
              %>
            </tbody>
          </table>
        </div>
      <%
        }
      %>
    </div>
  </div>
</div>
</body>
</html>
