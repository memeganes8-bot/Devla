<%@ page import="java.sql.*, java.io.*, com.itextpdf.text.*, com.itextpdf.text.pdf.*" %>
<%@ include file="includes/BD.jsp" %>
<%
  response.setContentType("application/pdf");
  response.setHeader("Content-Disposition","attachment;filename=reporte_inmobiliaria.pdf");

  Document document = new Document();
  PdfWriter.getInstance(document, response.getOutputStream());
  document.open();

  // --- Título principal ---
  Paragraph titulo = new Paragraph("Reporte General de la Inmobiliaria",
                                   FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18));
  titulo.setAlignment(Element.ALIGN_CENTER);
  document.add(titulo);
  document.add(new Paragraph(" "));
  document.add(new Paragraph("Generado en: " + new java.util.Date()));
  document.add(new Paragraph("------------------------------------------------------------"));
  document.add(new Paragraph(" "));

  // ============================
  // SECCIÓN 1: Usuarios
  // ============================
  document.add(new Paragraph("Usuarios Registrados", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14)));
  document.add(new Paragraph(" "));

  PdfPTable tablaUsuarios = new PdfPTable(4);
  tablaUsuarios.addCell("ID");
  tablaUsuarios.addCell("Nombre");
  tablaUsuarios.addCell("Email");
  tablaUsuarios.addCell("Rol");

  try (Connection conn = getConnection();
       Statement st = conn.createStatement();
       ResultSet rs = st.executeQuery(
         "SELECT u.id_usuario, u.nombre, u.email, r.nombre_rol " +
         "FROM usuarios u JOIN roles r ON u.id_rol=r.id_rol")) {
    while (rs.next()) {
      tablaUsuarios.addCell(String.valueOf(rs.getInt("id_usuario")));
      tablaUsuarios.addCell(rs.getString("nombre"));
      tablaUsuarios.addCell(rs.getString("email"));
      tablaUsuarios.addCell(rs.getString("nombre_rol"));
    }
  }
  document.add(tablaUsuarios);
  document.add(new Paragraph(" "));

  // ============================
  // SECCIÓN 2: Propiedades
  // ============================
  document.add(new Paragraph("Propiedades Disponibles", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14)));
  document.add(new Paragraph(" "));

  PdfPTable tablaPropiedades = new PdfPTable(5);
  tablaPropiedades.addCell("ID");
  tablaPropiedades.addCell("Título");
  tablaPropiedades.addCell("Descripción");
  tablaPropiedades.addCell("Ubicación");
  tablaPropiedades.addCell("Precio");

  try (Connection conn = getConnection();
       Statement st = conn.createStatement();
       ResultSet rs = st.executeQuery(
         "SELECT id_propiedad, titulo, descripcion, ubicacion, precio " +
         "FROM propiedades WHERE disponible=1")) {
    while (rs.next()) {
      tablaPropiedades.addCell(String.valueOf(rs.getInt("id_propiedad")));
      tablaPropiedades.addCell(rs.getString("titulo"));
      tablaPropiedades.addCell(rs.getString("descripcion"));
      tablaPropiedades.addCell(rs.getString("ubicacion"));
      tablaPropiedades.addCell(String.valueOf(rs.getDouble("precio")));
    }
  }
  document.add(tablaPropiedades);
  document.add(new Paragraph(" "));

  // ============================
  // SECCIÓN 3: Citas
  // ============================
  document.add(new Paragraph("Citas Registradas", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14)));
  document.add(new Paragraph(" "));

  PdfPTable tablaCitas = new PdfPTable(5);
  tablaCitas.addCell("ID Cita");
  tablaCitas.addCell("Cliente");
  tablaCitas.addCell("Propiedad");
  tablaCitas.addCell("Fecha");
  tablaCitas.addCell("Estado");

  try (Connection conn = getConnection();
       Statement st = conn.createStatement();
       ResultSet rs = st.executeQuery(
         "SELECT c.id_cita, u.nombre AS cliente, p.titulo AS propiedad, c.fecha, c.estado " +
         "FROM citas c " +
         "JOIN usuarios u ON c.cliente_id=u.id_usuario " +
         "JOIN propiedades p ON c.propiedad_id=p.id_propiedad")) {
    while (rs.next()) {
      tablaCitas.addCell(String.valueOf(rs.getInt("id_cita")));
      tablaCitas.addCell(rs.getString("cliente"));
      tablaCitas.addCell(rs.getString("propiedad"));
      tablaCitas.addCell(rs.getString("fecha"));
      tablaCitas.addCell(rs.getString("estado"));
    }
  }
  document.add(tablaCitas);

  // --- Cerrar documento ---
  document.close();
%>
