# =============================================================================
# Dockerfile - Backend Spring Boot (periferia-backend)
# Multi-stage build: compila con Maven+JDK 17 y corre con JRE 17
# =============================================================================

# ---------- Etapa 1: build ----------
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

# Cacheamos dependencias primero (capa reutilizable si el pom.xml no cambia)
COPY pom.xml .
RUN mvn -q -B dependency:go-offline

# Ahora copiamos el código y compilamos
COPY src ./src
RUN mvn -q -B clean package -DskipTests

# ---------- Etapa 2: runtime ----------
FROM eclipse-temurin:17-jre-jammy AS runtime
WORKDIR /app

# Usuario no-root
RUN groupadd -r spring && useradd -r -g spring spring

COPY --from=build /app/target/*.jar app.jar
RUN chown spring:spring app.jar
USER spring

# server.port=8080 (definido en application.properties)
EXPOSE 8080

# Healthcheck TCP simple (no requiere Spring Boot Actuator).
# Si más adelante agregan spring-boot-starter-actuator, se puede cambiar
# por: curl -f http://localhost:8080/api/v1/actuator/health
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=5 \
    CMD bash -c 'exec 3<>/dev/tcp/127.0.0.1/8080' || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
