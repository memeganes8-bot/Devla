<%@ include file="../includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
  // Verificación de rol admin
  if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("rol"))) {
    response.sendRedirect("../login.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Panel de Administrador</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-4">
  <h1>Bienvenido, Administrador</h1>
  <p>Gestione todo el sistema desde aquí:</p>
  <div class="list-group">
    <a href="listarUsuarios.jsp" class="list-group-item list-group-item-action">👤 Gestión de Usuarios</a>
    <a href="listarPropiedades.jsp" class="list-group-item list-group-item-action">🏠 Gestión de Propiedades</a>
    <a href="reportes.jsp" class="list-group-item list-group-item-action">📊 Reportes</a>
    <a href="../logout.jsp" class="list-group-item list-group-item-action text-danger">🚪 Cerrar sesión</a>
  </div>
</div>
</body>
</html>
