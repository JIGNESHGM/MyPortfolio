# Stage 1: Build Stage
FROM ubuntu:20.04 AS build

# Set environment variables to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary utilities
RUN apt-get update && apt-get install -y \
    wget curl tar unzip maven && \
    rm -rf /var/lib/apt/lists/*

# Download and install OpenJDK 23 from Adoptium
RUN wget https://github.com/AdoptOpenJDK/openjdk23/releases/download/jdk-23%2B32/OpenJDK23U-jdk_x64_linux_hotspot_23_32.tar.gz -P /tmp && \
    tar -xvf /tmp/OpenJDK23U-jdk_x64_linux_hotspot_23_32.tar.gz -C /opt && \
    rm /tmp/OpenJDK23U-jdk_x64_linux_hotspot_23_32.tar.gz

# Set environment variables for Java 23
ENV JAVA_HOME=/opt/jdk-23
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

# Copy OpenJDK 23 from the build stage
COPY --from=build /opt/jdk-23 /opt/jdk-23

# Set environment variables for Java 23
ENV JAVA_HOME=/opt/jdk-23
ENV PATH=$JAVA_HOME/bin:$PATH

# Verify Java version
RUN java --version

# Copy the built JAR file
COPY --from=build /app/target/*.jar /app/app.jar

# Expose the application port
EXPOSE 8081

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
