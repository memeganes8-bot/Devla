<%@ include file="../includes/BD.jsp" %>
<%
  int totalUsuarios=0,totalPropiedades=0,propDisponibles=0;
  try (Connection conn = getConnection()) {
    try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM usuarios");
         ResultSet rs = ps.executeQuery()) { if(rs.next()) totalUsuarios=rs.getInt(1); }
    try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM propiedades");
         ResultSet rs = ps.executeQuery()) { if(rs.next()) totalPropiedades=rs.getInt(1); }
    try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM propiedades WHERE disponible=1");
         ResultSet rs = ps.executeQuery()) { if(rs.next()) propDisponibles=rs.getInt(1); }
  } catch(Exception e){ out.println("Error: "+e.getMessage()); }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Reportes</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-4">
  <h2>Reportes del Sistema</h2>
  <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Volver al Dashboard</a>
  <ul class="list-group">
    <li class="list-group-item">Usuarios registrados: <strong><%= totalUsuarios %></strong></li>
    <li class="list-group-item">Propiedades registradas: <strong><%= totalPropiedades %></strong></li>
    <li class="list-group-item">Propiedades disponibles: <strong><%= propDisponibles %></strong></li>
  </ul>
</div>
</body>
</html>
