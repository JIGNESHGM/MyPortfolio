# Stage 1: Build Stage
FROM ubuntu:20.04 AS build

# Set environment variables to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary tools and OpenJDK 17
RUN apt-get update && apt-get install -y \
    wget curl tar openjdk-17-jdk unzip && \
    rm -rf /var/lib/apt/lists/*

# Set the environment variables for OpenJDK
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Verify Java version
RUN java --version

# Set working directory
WORKDIR /app

# Copy the project files
COPY . /app

# Ensure the Gradle wrapper is executable
RUN chmod +x gradlew

# Defensive measure: Ensure the Gradle Wrapper JAR is available
RUN if [ ! -f gradle/wrapper/gradle-wrapper.jar ]; then \
        echo "Gradle Wrapper JAR is missing. Downloading..."; \
        mkdir -p gradle/wrapper && \
        curl -o gradle/wrapper/gradle-wrapper.jar \
        https://services.gradle.org/distributions/gradle-7.6-bin.zip; \
    fi

# Build the Spring Boot application
RUN ./gradlew bootjar --no-daemon

# Stage 2: Runtime Stage
FROM ubuntu:20.04

# Set environment variables to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies and OpenJDK 17
RUN apt-get update && apt-get install -y \
    openjdk-17-jre && \
    rm -rf /var/lib/apt/lists/*

# Set the environment variables for OpenJDK
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Copy the built JAR from the build stage
COPY --from=build /app/build/libs/*.jar /app/app.jar

# Verify Java version
RUN java --version

# Expose the application port
EXPOSE 8081

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
