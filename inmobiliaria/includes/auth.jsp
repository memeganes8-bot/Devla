<%@ page session="true" %>
<%
  String role = (String) session.getAttribute("role");
  if (role == null) {
    response.sendRedirect("login.jsp"); // sin request.getContextPath() si todo está en la misma carpeta
    return;
  }

  // Si la página requiere un rol específico
  String requiredRole = (String) request.getAttribute("requiredRole");
  if (requiredRole != null && !requiredRole.equalsIgnoreCase(role)) {
    response.sendRedirect("index.jsp");
    return;
  }
%>
