# Stage 1: Build Stage
FROM ubuntu:20.04 AS build

# Set environment variables to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary tools and OpenJDK 23
RUN apt-get update && apt-get install -y \
    wget curl tar unzip openjdk-23-jdk maven && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables for Java 23
ENV JAVA_HOME=/usr/lib/jvm/java-23-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Verify Java version
RUN java --version

# Set working directory
WORKDIR /app

# Copy the project files
COPY . /app

# Build the Spring Boot application using Maven
RUN mvn clean package -DskipTests

# Stage 2: Runtime Stage
FROM ubuntu:20.04

# Install runtime dependencies and OpenJDK 23
RUN apt-get update && apt-get install -y \
    openjdk-23-jre && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables for Java 23
ENV JAVA_HOME=/usr/lib/jvm/java-23-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Copy the built JAR from the build stage
COPY --from=build /app/target/*.jar /app/app.jar

# Verify Java version
RUN java --version

# Expose the application port
EXPOSE 8080

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
