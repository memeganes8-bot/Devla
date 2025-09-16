<%@ include file="includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String q = request.getParameter("q");
  java.util.List<java.util.Map<String,Object>> destacados = new java.util.ArrayList<>();
  try (Connection conn = getConnection()) {
    String sql = "SELECT id_propiedad, titulo, precio, ubicacion, tipo, fotos FROM propiedades WHERE disponible=1"
               + (q!=null && !q.trim().isEmpty() ? " AND (titulo LIKE ? OR ubicacion LIKE ? OR tipo LIKE ?)" : "")
               + " ORDER BY creado_en DESC LIMIT 6";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
      if (q!=null && !q.trim().isEmpty()) {
        String like = "%" + q + "%";
        ps.setString(1, like);
        ps.setString(2, like);
        ps.setString(3, like);
      }
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          java.util.Map<String,Object> row = new java.util.HashMap<>();
          row.put("id", rs.getInt("id_propiedad"));
          row.put("titulo", rs.getString("titulo"));
          row.put("precio", rs.getBigDecimal("precio"));
          row.put("ubicacion", rs.getString("ubicacion"));
          row.put("tipo", rs.getString("tipo"));
          row.put("fotos", rs.getString("fotos"));
          destacados.add(row);
        }
      }
    }
  } catch(Exception e) {
    out.println("Error: "+e.getMessage());
  }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Inmobiliaria - Inicio</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body {
      background: #f8f9fa;
    }
    .hero {
      background: url('https://plus.unsplash.com/premium_photo-1661883964999-c1bcb57a7357?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Y2FzYSUyMGlubW9iaWxpYXJpYXxlbnwwfHwwfHx8MA%3D%3D') no-repeat center center;
      background-size: cover;
      color: white;
      padding: 80px 0;
      text-align: center;
    }
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
    <a class="navbar-brand" href="index.jsp"> Mi Inmobiliaria</a>
    <div>
      <a class="btn btn-outline-light me-2" href="propiedades.jsp">Propiedades</a>
      <%
        if (session.getAttribute("userId") == null) {
      %>
        <a class="btn btn-light" href="login.jsp">Entrar</a>
      <%
        } else {
      %>
        <a class="btn btn-warning" href="logout.jsp">Salir</a>
      <%
        }
      %>
    </div>
  </div>
</nav>

<!-- Hero con imagen -->
<div class="hero">
  <div class="container">
    <h1 class="display-4 fw-bold">Encuentra tu hogar ideal</h1>
    <p class="lead">Las mejores propiedades a un clic de distancia</p>
    <form method="get" action="index.jsp" class="row g-2 justify-content-center mt-4">
      <div class="col-md-6">
        <input class="form-control form-control-lg" placeholder="Buscar por título, ubicación o tipo" name="q" value="<%= (q!=null?q:"") %>">
      </div>
      <div class="col-md-2">
        <button class="btn btn-primary btn-lg w-100" type="submit">Buscar</button>
      </div>
    </form>
  </div>
</div>

<div class="container my-5">
  <h3 class="mb-4">✨ Propiedades destacadas</h3>
  <div class="row">
    <% for (java.util.Map<String,Object> p : destacados) { %>
      <div class="col-md-4">
        <div class="card shadow-sm mb-4">
          <%
            String tipo = (String)p.get("tipo");
            String foto = (p.get("fotos") != null && !((String)p.get("fotos")).isEmpty())
                          ? ((String)p.get("fotos")).split(",")[0]
                          : null;

            // Imagen por defecto según tipo
            if (foto == null) {
              if ("casa".equalsIgnoreCase(tipo)) {
                foto = "https://blog.wasi.co/wp-content/uploads/2019/07/claves-fotografia-inmobiliaria-exterior-casa-software-inmobiliario-wasi.jpg";
              } else if ("apartamento".equalsIgnoreCase(tipo)) {
                foto = "https://images.squarespace-cdn.com/content/v1/54ec0fb3e4b0dc5d50410043/1569958186329-5AY0JJSOYK6GTOS08XRD/foto-arquitectura-inmuebles-sala-apartamento-cerros-de-los-alpes.jpg?format=2500w";
              } else if ("terreno".equalsIgnoreCase(tipo)) {
                foto = "https://img.freepik.com/foto-gratis/vista-terreno-desarrollo-inmobiliario-empresarial_23-2149916719.jpg?semt=ais_hybrid&w=740&q=80";
              } else {
                foto = "https://via.placeholder.com/400x250";
              }
            }
          %>
          <img src="<%= foto %>" class="card-img-top" alt="">

          <div class="card-body">
            <h5 class="card-title"><%= p.get("titulo") %></h5>
            <p class="text-muted"><%= p.get("ubicacion") %></p>
            <p class="fw-bold text-primary">$<%= p.get("precio") %></p>
            <a class="btn btn-sm btn-outline-primary" href="detallePropiedad.jsp?id=<%= p.get("id") %>">Ver detalle</a>
          </div>
        </div>
      </div>
    <% } %>
  </div>
</div>

<footer>
  <div class="container">
    <p>© 2025 Mi Inmobiliaria - Todos los derechos reservados</p>
  </div>
</footer>
</body>
</html>
