<%@ include file="includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String idStr = request.getParameter("id");
  if (idStr == null) { response.sendRedirect("propiedades.jsp"); return; }
  int id = Integer.parseInt(idStr);
  java.util.Map<String,Object> p = null;
  try (Connection conn = getConnection();
       PreparedStatement ps = conn.prepareStatement(
         "SELECT p.*, u.nombre AS inmo_nombre, u.email AS inmo_email " +
         "FROM propiedades p LEFT JOIN usuarios u ON p.id_usuario=u.id_usuario " +
         "WHERE id_propiedad=?")) {
    ps.setInt(1, id);
    try (ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        p = new java.util.HashMap<>();
        p.put("id", rs.getInt("id_propiedad"));
        p.put("titulo", rs.getString("titulo"));
        p.put("descripcion", rs.getString("descripcion"));
        p.put("precio", rs.getBigDecimal("precio"));
        p.put("ubicacion", rs.getString("ubicacion"));
        p.put("tipo", rs.getString("tipo"));
        p.put("fotos", rs.getString("fotos"));
        p.put("inmo_nombre", rs.getString("inmo_nombre"));
        p.put("inmo_email", rs.getString("inmo_email"));
      } else {
        response.sendRedirect("propiedades.jsp");
        return;
      }
    }
  } catch(Exception e) { out.println("Error: "+e.getMessage()); }

  // Definir imágenes por tipo si no hay en BD
  String tipoP = (String)p.get("tipo");
  String[] imgs;

  if ("casa".equalsIgnoreCase(tipoP)) {
    imgs = new String[]{
      "https://blog.wasi.co/wp-content/uploads/2019/07/claves-fotografia-inmobiliaria-exterior-casa-software-inmobiliario-wasi.jpg"
    };
  } else if ("apartamento".equalsIgnoreCase(tipoP)) {
    imgs = new String[]{
      "https://images.squarespace-cdn.com/content/v1/54ec0fb3e4b0dc5d50410043/1569958186329-5AY0JJSOYK6GTOS08XRD/foto-arquitectura-inmuebles-sala-apartamento-cerros-de-los-alpes.jpg?format=2500w"
    };
  } else if ("terreno".equalsIgnoreCase(tipoP)) {
    imgs = new String[]{
      "https://img.freepik.com/foto-gratis/vista-terreno-desarrollo-inmobiliario-empresarial_23-2149916719.jpg?semt=ais_hybrid&w=740&q=80"
    };
  } else {
    imgs = new String[]{ "https://via.placeholder.com/800x500" };
  }

  String primeraFoto = imgs[0];
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title><%= p.get("titulo") %></title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body { background: #f8f9fa; }
    footer {
      margin-top: 50px;
      background: #212529;
      color: #ddd;
      padding: 20px 0;
      text-align: center;
    }
  </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container">
    <a class="navbar-brand" href="index.jsp">🏠 Mi Inmobiliaria</a>
    <div>
      <a class="btn btn-outline-light me-2" href="propiedades.jsp">Propiedades</a>
      <% if (session.getAttribute("userId")!=null) { %>
        <a class="btn btn-warning" href="logout.jsp">Salir</a>
      <% } else { %>
        <a class="btn btn-light" href="login.jsp">Entrar</a>
      <% } %>
    </div>
  </div>
</nav>

<div class="container mt-4">
  <a class="btn btn-link mb-3" href="propiedades.jsp">← Volver</a>
  <div class="row">
    <!-- Columna imágenes -->
    <div class="col-md-7">
      <div class="card shadow-sm mb-3">
        <img src="<%= primeraFoto %>" class="card-img-top img-fluid"
             onerror="this.src='https://via.placeholder.com/800x500'" alt="Imagen principal">
      </div>
    </div>

    <!-- Columna info -->
    <div class="col-md-5">
      <div class="card shadow-sm p-3">
        <h2 class="mb-3"><%= p.get("titulo") %></h2>
        <p><strong>Precio:</strong> <span class="text-success">$<%= p.get("precio") %></span></p>
        <p><strong>Ubicación:</strong> <%= p.get("ubicacion") %></p>
        <p><strong>Tipo:</strong> <%= p.get("tipo") %></p>
        <p><strong>Descripción:</strong><br><%= p.get("descripcion") %></p>
        <hr>
        <p><strong>Publicado por:</strong><br> <%= p.get("inmo_nombre") %> (<%= p.get("inmo_email") %>)</p>

        <% if (session.getAttribute("userId") == null) { %>
          <a class="btn btn-primary w-100" href="login.jsp">Inicia sesión para solicitar cita</a>
        <% } else { %>
          <a class="btn btn-success w-100" href="solicitarCita.jsp?propiedad_id=<%= p.get("id") %>">Solicitar cita</a>
        <% } %>
      </div>
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
