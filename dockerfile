# Usar una imagen base de Tomcat 8 con JDK
FROM tomcat:8.5-jdk8

# Definir el directorio donde irá la aplicación JSP
WORKDIR /usr/local/tomcat/webapps/

# Copiar la carpeta del proyecto dentro de Tomcat
COPY ./inmobiliariaweb /usr/local/tomcat/webapps/INMOBILIARIAWEB/

# Copiar los conectores y librerías dentro de Tomcat/lib
COPY ./inmobiliariaweb/WEB-INF/lib/mysql-connector-j-9.2.0.jar /usr/local/tomcat/lib/
COPY ./inmobiliariaweb/WEB-INF/lib/itextpdf-5.5.13.3.jar /usr/local/tomcat/lib/
# Si no usas PostgreSQL, no copies ese JAR
# COPY ./inmobiliariaweb/WEB-INF/lib/postgresql-42.2.19.jar /usr/local/tomcat/lib/

# Exponer el puerto 8080
EXPOSE 8080

# Comando de inicio de Tomcat
CMD ["catalina.sh", "run"]




