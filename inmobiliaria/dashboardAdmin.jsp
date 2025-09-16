<%@ include file="includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  Integer userId = (Integer) session.getAttribute("userId");
  String role = (String) session.getAttribute("role");

  if (userId == null || role == null || !"admin".equalsIgnoreCase(role)) {
    response.sendRedirect("login.jsp");
    return;
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Panel de Administración</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
  <div class="card shadow-sm">
    <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
      <h4 class="mb-0">⚙️ Panel de Administración</h4>
      <span class="fw-light">Bienvenido, <strong><%= session.getAttribute("username") %></strong></span>
    </div>
    <div class="card-body">
      <div class="list-group">
        <a href="adminUsuarios.jsp" class="list-group-item list-group-item-action">
          👥 Gestión de Usuarios
        </a>
        <a href="adminPropiedades.jsp" class="list-group-item list-group-item-action">
          🏠 Gestión de Propiedades
        </a>
        <a href="adminCitas.jsp" class="list-group-item list-group-item-action">
          📅 Gestión de Citas
        </a>
        <a href="reporte.jsp" class="list-group-item list-group-item-action">
          📊 Reportes (PDF)
        </a>
        <a href="logout.jsp" class="list-group-item list-group-item-action text-danger">
          🚪 Cerrar Sesión
        </a>
      </div>
    </div>
  </div>
</div>
</body>
</html>
