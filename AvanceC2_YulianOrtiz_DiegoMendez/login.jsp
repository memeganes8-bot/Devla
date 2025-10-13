<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
// Verificar autenticación
String usuarioId = (String) session.getAttribute("usuario_id");
if (usuarioId != null) {
    response.sendRedirect("dashboard.jsp");
    return;
}

// Procesar login
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://unsp1ogkp7qbzhgm:ZXCRqDEJJIyGydtVjg3G@bffswfi9tjiywn5lfs3q-mysql.services.clever-cloud.com:3306/bffswfi9tjiywn5lfs3q", 
            "unsp1ogkp7qbzhgm", 
            "ZXCRqDEJJIyGydtVjg3G"
        );
        
        String sql = "SELECT id, cedula, nombre, rol, area_conocimiento, estado FROM usuarios WHERE email = ? AND password = ? AND estado = 'activo'";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, email);
        pstmt.setString(2, password);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            // Login exitoso
            session.setAttribute("usuario_id", rs.getString("id"));
            session.setAttribute("usuario_cedula", rs.getString("cedula"));
            session.setAttribute("usuario_nombre", rs.getString("nombre"));
            session.setAttribute("usuario_rol", rs.getString("rol"));
            session.setAttribute("usuario_email", email);
            session.setAttribute("usuario_area", rs.getString("area_conocimiento"));
            
            response.sendRedirect("dashboard.jsp");
            return;
        } else {
            out.println("<div class='alert alert-error'>❌ Usuario o contraseña incorrectos</div>");
        }
        
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>❌ Error: " + e.getMessage() + "</div>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - UTS</title>
    <link rel="stylesheet" href="css/styles.css">
    <style>
        body {
            background-image: url('img/fondo2.png');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 20px;
        }
        .login-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
            overflow: hidden;
            max-width: 450px;
            width: 100%;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .login-header {
            background: linear-gradient(135deg, var(--uts-red) 0%, var(--uts-light-red) 100%);
            color: var(--uts-white);
            padding: 30px 20px;
            text-align: center;
        }
        .uts-logo {
            height: 60px;
            margin-bottom: 15px;
        }
        .login-title {
            font-size: 1.4em;
            font-weight: bold;
            margin: 0;
        }
        .login-subtitle {
            font-size: 0.9em;
            opacity: 0.9;
            margin: 5px 0 0 0;
        }
        .login-form {
            padding: 30px;
        }
        .btn-login {
            width: 100%;
            padding: 12px;
            background: var(--uts-red);
            color: var(--uts-white);
            border: none;
            border-radius: 8px;
            font-size: 1em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 10px;
        }
        .btn-login:hover {
            background: var(--uts-dark-red);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(139, 0, 0, 0.3);
        }
        .demo-credentials {
            background: rgba(248, 249, 250, 0.8);
            padding: 20px;
            border-radius: 8px;
            margin-top: 25px;
            font-size: 0.85em;
            border-left: 4px solid var(--uts-red);
            backdrop-filter: blur(5px);
        }
        .demo-credentials h4 {
            margin: 0 0 15px 0;
            color: var(--uts-red);
            font-size: 1.1em;
        }
        .credential-item {
            margin-bottom: 12px;
            padding-bottom: 12px;
            border-bottom: 1px solid rgba(224, 224, 224, 0.5);
        }
        .credential-item:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }
        .role-badge {
            display: inline-block;
            background: var(--uts-red);
            color: var(--uts-white);
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 0.75em;
            margin-left: 8px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <img src="img/Logo-UTS-1.png" alt="Logo UTS" class="uts-logo">
            <h1 class="login-title">Unidades Tecnol&#243;gicas de Santander</h1>
            <p class="login-subtitle">Sistema de Gesti&#243;n de Trabajos de Grado</p>
        </div>
        
        <div class="login-form">
            <h2 style="text-align: center; color: var(--uts-red); margin-bottom: 30px; font-size: 1.5em;">Iniciar Sesi&#243;n</h2>
            
            <form method="POST" action="login.jsp">
                <div class="form-group">
                    <label for="email">Correo Electr&#243;nico:</label>
                    <input type="email" class="form-control" id="email" name="email" required 
                           placeholder="usuario@uts.edu.co">
                </div>
                
                <div class="form-group">
                    <label for="password">Contrase&#241;a:</label>
                    <input type="password" class="form-control" id="password" name="password" required 
                           placeholder="Ingresa tu contrase&#241;a">
                </div>
                
                <button type="submit" class="btn-login">🎓 Ingresar al Sistema</button>
            </form>
            
            <div class="demo-credentials">
                <h4>🔑 Usuarios de Prueba:</h4>
                <div class="credential-item">
                    <strong>admin@uts.edu.co</strong> <span class="role-badge">ADMIN</span><br>
                    <small>Contrase&#241;a: admin123</small>
                </div>
                <div class="credential-item">
                    <strong>martes@uts.edu.co</strong> <span class="role-badge">ESTUDIANTE</span><br>
                    <small>Contrase&#241;a: estudiante123</small>
                </div>
                <div class="credential-item">
                    <small>Los usuarios que registres también funcionarán</small>
                </div>
            </div>
        </div>
    </div>
</body>
</html>