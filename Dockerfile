FROM maven:3.9.4-eclipse-temurin-17 AS builder
WORKDIR /src
COPY pom.xml mvnw ./
COPY . .

RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw dependency:go-offline

RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw clean package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=builder /src/target/*.jar app.jar
EXPOSE 9191
ENTRYPOINT ["java","-jar","/app/app.jar"]