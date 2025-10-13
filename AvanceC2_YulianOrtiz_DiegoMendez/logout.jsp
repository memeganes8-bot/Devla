<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// Configurar headers para evitar cache
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setHeader("Expires", "0");

// Invalidar la sesión completamente
session.invalidate();

// Redirigir al login con parámetro de logout
response.sendRedirect(request.getContextPath() + "/login.jsp?logout=success");
%>