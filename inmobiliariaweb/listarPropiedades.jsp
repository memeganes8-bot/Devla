<%@ include file="includes/BD.jsp" %>
<%
  // Validación de sesión y rol
  String role = (String) session.getAttribute("role");
  if (session.getAttribute("userId") == null || role == null || 
      !( "admin".equalsIgnoreCase(role) || "inmobiliaria".equalsIgnoreCase(role) )) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }

  java.util.List<java.util.Map<String,Object>> props = new java.util.ArrayList<>();
  String errorMsg = null;

  try (Connection conn = getConnection();
       PreparedStatement ps = conn.prepareStatement(
         "SELECT id_propiedad, titulo, precio, ubicacion, disponible FROM propiedades ORDER BY id_propiedad DESC")) {
    try (ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        java.util.Map<String,Object> p = new java.util.HashMap<>();
        p.put("id", rs.getInt("id_propiedad"));
        p.put("titulo", rs.getString("titulo"));
        p.put("precio", rs.getBigDecimal("precio"));
        p.put("ubicacion", rs.getString("ubicacion"));
        p.put("disponible", rs.getInt("disponible"));
        props.add(p);
      }
    }
  } catch(Exception e) { 
    errorMsg = e.getMessage();
  }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Propiedades registradas</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container">
    <a class="navbar-brand" href="index.jsp">Mi Inmobiliaria</a>
    <span class="navbar-text text-white">
      <strong><%= session.getAttribute("username") %></strong> 
      (<%= role %>)
    </span>
  </div>
</nav>

<div class="container mt-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h2 class="mb-0">Propiedades registradas</h2>
    <% if ("admin".equalsIgnoreCase(role)) { %>
      <a href="dashboard.jsp" class="btn btn-secondary">← Volver al Dashboard Admin</a>
    <% } else if ("inmobiliaria".equalsIgnoreCase(role)) { %>
      <a href="dashboardInmo.jsp" class="btn btn-secondary">Volver al panel Inmobiliaria</a>
    <% } %>
  </div>

  <% if (errorMsg != null) { %>
    <div class="alert alert-danger">❌ Error al cargar propiedades: <%= errorMsg %></div>
  <% } else if (props.isEmpty()) { %>
    <div class="alert alert-warning">⚠️ No hay propiedades registradas.</div>
  <% } else { %>
    <div class="table-responsive">
      <table class="table table-striped align-middle shadow-sm">
        <thead class="table-dark">
          <tr>
            <th>ID</th>
            <th>Titulo</th>
            <th>Precio</th>
            <th>Ubicacion</th>
            <th>Disponible</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
        <% for (java.util.Map<String,Object> p : props) { %>
          <tr>
            <td><%= p.get("id") %></td>
            <td><%= p.get("titulo") %></td>
            <td>$<%= new java.text.DecimalFormat("#,###").format(p.get("precio")) %></td>
            <td><%= p.get("ubicacion") %></td>
            <td>
              <% if ((int)p.get("disponible") == 1) { %>
                <span class="badge bg-success">Si</span>
              <% } else { %>
                <span class="badge bg-danger">No</span>
              <% } %>
            </td>
            <td>
              <a href="editarPropiedad.jsp?id=<%= p.get("id") %>" 
                 class="btn btn-sm btn-outline-primary me-2">Editar</a>
              <a href="eliminarPropiedad.jsp?id=<%= p.get("id") %>" 
                 class="btn btn-sm btn-danger"
                 onclick="return confirm('¿Seguro que deseas eliminar esta propiedad?')">
                 Eliminar
              </a>
            </td>
          </tr>
        <% } %>
        </tbody>
      </table>
    </div>
  <% } %>
</div>

<footer class="bg-dark text-light text-center py-3 mt-auto fixed-bottom">
  <div class="container">
    <p>© 2025 Mi Inmobiliaria - Todos los derechos reservados</p>
  </div>
</footer>

</body>
</html>
