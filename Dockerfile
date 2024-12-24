# Stage 1: Build Stage
FROM ubuntu:20.04 AS build

# Install OpenJDK 17 and dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk maven wget curl tar unzip && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables for OpenJDK 17
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
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

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    wget curl tar unzip && \
    rm -rf /var/lib/apt/lists/*

# Copy OpenJDK 17 from the build stage
COPY --from=build /usr/lib/jvm/java-17-openjdk-amd64 /usr/lib/jvm/java-17-openjdk-amd64

# Set Java environment
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Verify Java version
RUN java --version

# Copy the built JAR file
COPY --from=build /app/target/*.jar /app/app.jar

# Expose the application port
EXPOSE 8081

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
