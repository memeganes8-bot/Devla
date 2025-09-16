<%@ include file="../includes/BD.jsp" %>
<%
  if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("rol"))) {
    response.sendRedirect("../login.jsp");
    return;
  }

  String idStr = request.getParameter("id");
  if (idStr != null) {
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement("DELETE FROM propiedades WHERE id_propiedad=?")) {
      ps.setInt(1, Integer.parseInt(idStr));
      ps.executeUpdate();
    }
  }
  response.sendRedirect("listarPropiedades.jsp");
%>
