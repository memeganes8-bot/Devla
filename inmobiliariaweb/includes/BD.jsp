<%@ page import="java.sql.*, java.security.MessageDigest, java.math.BigInteger" %>
<%!
  // Cambia estos valores por los de tu Clever Cloud o local
  private String DB_URL = "jdbc:mysql://uudaozx7qp1ooxb9:y9oUTlTZELdLvHmBYVLu@bnmjala0qkvuhxaajjqq-mysql.services.clever-cloud.com:3306/bnmjala0qkvuhxaajjqq";
  private String DB_USER = "uudaozx7qp1ooxb9";
  private String DB_PASS = "y9oUTlTZELdLvHmBYVLu";

  public Connection getConnection() throws SQLException {
    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
      throw new RuntimeException("JDBC Driver no encontrado: " + e.getMessage(), e);
    }
    return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
  }

  public String sha256(String input) {
    try {
      MessageDigest md = MessageDigest.getInstance("SHA-256");
      byte[] digest = md.digest(input.getBytes("UTF-8"));
      BigInteger number = new BigInteger(1, digest);
      StringBuilder hex = new StringBuilder(number.toString(16));
      while (hex.length() < 64) hex.insert(0, '0');
      return hex.toString();
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }
%>
