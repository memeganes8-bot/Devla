<%
  request.setAttribute("requiredRole", "inmobiliaria");
%>
<%@ include file="includes/auth.jsp" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Panel Inmobiliaria</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container">
    <a class="navbar-brand" href="index.jsp">Mi Inmobiliaria</a>
    <div>
      <a class="btn btn-outline-light me-2" href="index.jsp">Inicio</a>
      <a class="btn btn-warning" href="logout.jsp">Salir</a>
    </div>
  </div>
</nav>

<div class="container mt-4">
  <div class="card shadow-sm p-4">
    <h1 class="mb-3">Panel de Inmobiliaria</h1>
    <p class="lead">
      Bienvenido <strong><%= session.getAttribute("username") %></strong>  
      <span class="badge bg-info text-dark">Rol: <%= session.getAttribute("role") %></span>
    </p>
    <hr>

    <div class="list-group">
      <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center" href="listarPropiedades.jsp">
        Listar Propiedades <span class="badge bg-primary rounded-pill">Ver</span>
      </a>
      <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center" href="agregarPropiedad.jsp">
        Agregar Propiedad <span class="badge bg-success rounded-pill">Nuevo</span>
      </a>
      <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center" href="misCitas.jsp">
        Ver Solicitudes de Citas <span class="badge bg-warning rounded-pill">Pendientes</span>
      </a>
      <a class="list-group-item list-group-item-action text-danger d-flex justify-content-between align-items-center" href="logout.jsp">
        Cerrar Sesion
      </a>
    </div>
  </div>
</div>

<footer class="bg-dark text-light text-center py-3 mt-auto fixed-bottom">
  <div class="container">
    <p>© 2025 MiInmobiliaria - Todos los derechos reservados</p>
  </div>
</footer>

</body>
</html>
