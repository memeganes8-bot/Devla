<%@ page import="java.sql.*, java.util.*, java.util.HashMap" %>
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

  // --- Eliminar cita ---
  if ("eliminar".equals(request.getParameter("action"))) {
    int idCita = Integer.parseInt(request.getParameter("id"));
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement("DELETE FROM citas WHERE id_cita=?")) {
      ps.setInt(1, idCita);
      ps.executeUpdate();
      msg = "✅ Cita eliminada correctamente.";
    } catch (Exception e) {
      msg = "Error al eliminar: " + e.getMessage();
    }
  }

  // --- Actualizar estado ---
  if ("estado".equals(request.getParameter("action"))) {
    int idCita = Integer.parseInt(request.getParameter("id"));
    String nuevoEstado = request.getParameter("nuevoEstado");
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement("UPDATE citas SET estado=? WHERE id_cita=?")) {
      ps.setString(1, nuevoEstado);
      ps.setInt(2, idCita);
      ps.executeUpdate();
      msg = "✅ Estado actualizado.";
    } catch (Exception e) {
      msg = "Error al actualizar estado: " + e.getMessage();
    }
  }

  // --- Consultar citas ---
  List<Map<String,Object>> citas = new ArrayList<>();
  try (Connection conn = getConnection();
       Statement st = conn.createStatement();
       ResultSet rs = st.executeQuery(
         "SELECT c.id_cita, c.fecha, c.estado, u.nombre AS cliente, p.titulo AS propiedad " +
         "FROM citas c " +
         "JOIN usuarios u ON c.cliente_id=u.id_usuario " +
         "JOIN propiedades p ON c.propiedad_id=p.id_propiedad"
       )) {

    while (rs.next()) {
      Map<String,Object> row = new HashMap<>();
      row.put("id_cita", rs.getInt("id_cita"));
      row.put("fecha", rs.getString("fecha"));
      row.put("estado", rs.getString("estado"));
      row.put("cliente", rs.getString("cliente"));
      row.put("propiedad", rs.getString("propiedad"));
      citas.add(row);
    }
  } catch (Exception e) {
    msg = "Error: " + e.getMessage();
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Gestión de Citas</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-4">
  <h2>📅 Gestión de Citas</h2>
  <a href="dashboardAdmin.jsp" class="btn btn-secondary mb-3">← Volver</a>
  <div class="text-success"><%= msg %></div>

  <table class="table table-bordered table-striped">
    <thead class="table-dark">
      <tr>
        <th>ID</th>
        <th>Fecha y hora</th>
        <th>Estado</th>
        <th>Cliente</th>
        <th>Propiedad</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody>
      <%
        for (Map<String,Object> c : citas) {
      %>
        <tr>
          <td><%= c.get("id_cita") %></td>
          <td><%= c.get("fecha") %></td>
          <td><%= c.get("estado") %></td>
          <td><%= c.get("cliente") %></td>
          <td><%= c.get("propiedad") %></td>
          <td>
            <!-- Cambiar estado -->
            <form method="post" action="adminCitas.jsp" style="display:inline;">
              <input type="hidden" name="action" value="estado">
              <input type="hidden" name="id" value="<%= c.get("id_cita") %>">
              <select name="nuevoEstado" class="form-select form-select-sm d-inline w-auto">
                <option value="pendiente">Pendiente</option>
                <option value="confirmada">Confirmada</option>
                <option value="cancelada">Cancelada</option>
              </select>
              <button class="btn btn-sm btn-primary">Actualizar</button>
            </form>

            <!-- Eliminar -->
            <form method="post" action="adminCitas.jsp" style="display:inline;" 
                  onsubmit="return confirm('¿Seguro que deseas eliminar esta cita?');">
              <input type="hidden" name="action" value="eliminar">
              <input type="hidden" name="id" value="<%= c.get("id_cita") %>">
              <button class="btn btn-sm btn-danger">Eliminar</button>
            </form>
          </td>
        </tr>
      <%
        }
        if (citas.isEmpty()) {
      %>
        <tr><td colspan="6" class="text-center">No hay citas registradas.</td></tr>
      <%
        }
      %>
    </tbody>
  </table>
</div>
</body>
</html>
