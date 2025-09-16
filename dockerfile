# Usar una imagen base de Tomcat 8 con JDK
FROM tomcat:8.5-jdk8

# Definir el directorio donde irá la aplicación JSP
WORKDIR /usr/local/tomcat/webapps/

# Copiar la carpeta del proyecto dentro de Tomcat
COPY ./WebContent /usr/local/tomcat/webapps/INMOBILIARIAWEB/

# Copiar el conector MySQL dentro de la carpeta lib de Tomcat
COPY /INMOBILIARIAWEB/WEB-INF/lib/mysql-connector-j-9.0.0.jar /usr/local/tomcat/lib/
COPY /INMOBILIARIAWEB/WEB-INF/lib/itextpdf-5.5.13.3.jar /usr/local/tomcat/lib/



# Exponer el puerto 8080 para acceder a la aplicación
EXPOSE 8080

# Comando de inicio de Tomcat
CMD ["catalina.sh", "run"]




