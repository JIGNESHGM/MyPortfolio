FROM ubuntu:latest AS build
RUN apt-get update
RUN apt-get install openjdk-23-jdk -y
COPY . .
RUN ./gradlew bootjar --no-daemon
FROM openjdk:23-jdk-slim
EXPOSE 8081
COPY --from=build /build/libs/demo-1.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]