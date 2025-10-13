# Imagen base: Tomcat con JDK 8
FROM tomcat:8.5-jdk8

# Definir el directorio de trabajo
WORKDIR /usr/local/tomcat/webapps/

# Copiar la carpeta del nuevo proyecto JSP dentro de Tomcat
COPY ./AvanceC2_YulianOrtiz_DiegoMendez /usr/local/tomcat/webapps/AvanceC2_YulianOrtiz_DiegoMendez/

# Copiar las librerías necesarias a la carpeta lib de Tomcat
COPY ./AvanceC2_YulianOrtiz_DiegoMendez/WEB-INF/lib/jakarta.servlet.jsp.jstl-api-3.0.2.jar /usr/local/tomcat/lib/
COPY ./AvanceC2_YulianOrtiz_DiegoMendez/WEB-INF/lib/jstl-1.2.jar /usr/local/tomcat/lib/
COPY ./AvanceC2_YulianOrtiz_DiegoMendez/WEB-INF/lib/mysql-connector-j-9.2.0.jar /usr/local/tomcat/lib/

# Exponer el puerto 8080
EXPOSE 8080

# Comando de inicio de Tomcat
CMD ["catalina.sh", "run"]

