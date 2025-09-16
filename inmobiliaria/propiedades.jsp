<%@ include file="includes/BD.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String tipo = request.getParameter("tipo");
  String minPrice = request.getParameter("min");
  String maxPrice = request.getParameter("max");
  String lugar = request.getParameter("lugar");

  java.util.List<java.util.Map<String,Object>> lista = new java.util.ArrayList<>();
  try (Connection conn = getConnection()) {
    StringBuilder sql = new StringBuilder("SELECT id_propiedad, titulo, precio, ubicacion, tipo, fotos, disponible FROM propiedades WHERE 1=1");
    java.util.List<Object> params = new java.util.ArrayList<>();
    if (tipo != null && !tipo.isEmpty()) { sql.append(" AND tipo=?"); params.add(tipo); }
    if (lugar != null && !lugar.isEmpty()) { sql.append(" AND ubicacion LIKE ?"); params.add("%"+lugar+"%"); }
    if (minPrice != null && !minPrice.isEmpty()) { sql.append(" AND precio >= ?"); params.add(new java.math.BigDecimal(minPrice)); }
    if (maxPrice != null && !maxPrice.isEmpty()) { sql.append(" AND precio <= ?"); params.add(new java.math.BigDecimal(maxPrice)); }
    sql.append(" ORDER BY creado_en DESC");

    try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
      for (int i=0;i<params.size();i++) ps.setObject(i+1, params.get(i));
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          java.util.Map<String,Object> r = new java.util.HashMap<>();
          r.put("id", rs.getInt("id_propiedad"));
          r.put("titulo", rs.getString("titulo"));
          r.put("precio", rs.getBigDecimal("precio"));
          r.put("ubicacion", rs.getString("ubicacion"));
          r.put("tipo", rs.getString("tipo"));
          r.put("fotos", rs.getString("fotos"));
          r.put("disponible", rs.getInt("disponible"));
          lista.add(r);
        }
      }
    }
  } catch(Exception e) { out.println("Error: "+e.getMessage()); }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Listado de propiedades</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body { background: #f8f9fa; }
    .card-img-top {
      height: 200px;
      object-fit: cover;
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
    <a class="navbar-brand" href="index.jsp">Mi Inmobiliaria</a>
    <div>
      <a class="btn btn-outline-light me-2" href="index.jsp">Inicio</a>
      <% if (session.getAttribute("userId")!=null) { %>
        <a class="btn btn-warning" href="logout.jsp">Salir</a>
      <% } else { %>
        <a class="btn btn-light" href="login.jsp">Entrar</a>
      <% } %>
    </div>
  </div>
</nav>

<div class="container mt-4">
  <div class="card mb-3 p-3 shadow-sm">
    <form class="row g-2" method="get" action="propiedades.jsp">
      <div class="col-md-3"><input name="lugar" class="form-control" placeholder="Ubicación" value="<%= (lugar!=null?lugar:"") %>"></div>
      <div class="col-md-2">
        <select name="tipo" class="form-select">
          <option value="">Tipo</option>
          <option value="casa" <%= "casa".equals(tipo)?"selected":"" %>>Casa</option>
          <option value="apartamento" <%= "apartamento".equals(tipo)?"selected":"" %>>Apartamento</option>
          <option value="terreno" <%= "terreno".equals(tipo)?"selected":"" %>>Terreno</option>
          <option value="oficina" <%= "oficina".equals(tipo)?"selected":"" %>>Oficina</option>
        </select>
      </div>
      <div class="col-md-2"><input name="min" type="number" step="0.01" class="form-control" placeholder="Mín $" value="<%= (minPrice!=null?minPrice:"") %>"></div>
      <div class="col-md-2"><input name="max" type="number" step="0.01" class="form-control" placeholder="Máx $" value="<%= (maxPrice!=null?maxPrice:"") %>"></div>
      <div class="col-md-3"><button class="btn btn-primary w-100" type="submit">Filtrar</button></div>
    </form>
  </div>

  <div class="row">
    <% for (java.util.Map<String,Object> p : lista) { 
         String tipoP = (String)p.get("tipo");
         String foto = (p.get("fotos") != null && !((String)p.get("fotos")).isEmpty())
                       ? ((String)p.get("fotos")).split(",")[0]
                       : "";
         String fallback = "https://via.placeholder.com/400x250";
         if ("casa".equalsIgnoreCase(tipoP)) {
           fallback = "https://blog.wasi.co/wp-content/uploads/2019/07/claves-fotografia-inmobiliaria-exterior-casa-software-inmobiliario-wasi.jpg";
         } else if ("apartamento".equalsIgnoreCase(tipoP)) {
           fallback = "https://images.squarespace-cdn.com/content/v1/54ec0fb3e4b0dc5d50410043/1569958186329-5AY0JJSOYK6GTOS08XRD/foto-arquitectura-inmuebles-sala-apartamento-cerros-de-los-alpes.jpg?format=2500w";
         } else if ("terreno".equalsIgnoreCase(tipoP)) {
           fallback = "https://img.freepik.com/foto-gratis/vista-terreno-desarrollo-inmobiliario-empresarial_23-2149916719.jpg?semt=ais_hybrid&w=740&q=80";
         }
    %>
      <div class="col-md-4">
        <div class="card shadow-sm mb-4">
          <img src="<%= foto.isEmpty()? fallback:foto %>" 
               class="card-img-top" 
               alt="Imagen propiedad"
               onerror="this.onerror=null;this.src='<%= fallback %>';">
          <div class="card-body">
            <h5 class="card-title"><%= p.get("titulo") %></h5>
            <p class="text-muted"><%= p.get("ubicacion") %></p>
            <p class="fw-bold text-primary">$<%= p.get("precio") %></p>
            <a class="btn btn-sm btn-outline-primary" href="detallePropiedad.jsp?id=<%= p.get("id") %>">Ver detalle</a>
            <% if (session.getAttribute("role")!=null && ("inmobiliaria".equals(session.getAttribute("role")) || "admin".equals(session.getAttribute("role")))) { %>
              <a class="btn btn-sm btn-outline-secondary" href="agregarPropiedad.jsp?edit=<%= p.get("id") %>">Editar</a>
            <% } %>
          </div>
        </div>
      </div>
    <% } %>
  </div>
</div>

<footer class="bg-dark text-light text-center py-3 mt-auto fixed-bottom">
  <div class="container">
    <p>© 2025 MiInmobiliaria - Todos los derechos reservados</p>
  </div>
</footer>

</body>
</html>
