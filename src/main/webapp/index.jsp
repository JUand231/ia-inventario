<%@ page pageEncoding="UTF-8" %>
<%-- Resaldo: si el contenedor no resuelve el welcome-file "inicio", aquí se redirige. --%>
<%
    response.sendRedirect(request.getContextPath() + "/inicio");
%>
