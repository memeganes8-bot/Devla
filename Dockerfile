# Usar imagen base de Java 21
FROM eclipse-temurin:21-jre-alpine

# Crear directorio de trabajo
WORKDIR /app

# Copiar el JAR generado
COPY target/saberpro.jar app.jar

# Exponer el puerto
EXPOSE 8080

# Comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]