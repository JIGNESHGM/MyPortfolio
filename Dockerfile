# Stage 1: Build Stage
FROM ubuntu:latest AS build

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    wget tar curl unzip && \
    rm -rf /var/lib/apt/lists/*

# Install OpenJDK 23
RUN wget -q https://download.java.net/java/early_access/jdk23/36/GPL/openjdk-23-ea+36_linux-x64_bin.tar.gz -O openjdk-23.tar.gz && \
    mkdir -p /usr/lib/jvm && \
    tar -xzf openjdk-23.tar.gz -C /usr/lib/jvm && \
    rm openjdk-23.tar.gz && \
    ln -s /usr/lib/jvm/jdk-23-ea+36 /usr/lib/jvm/default-jdk

# Set environment variables for JDK 23
ENV JAVA_HOME=/usr/lib/jvm/default-jdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Verify the Java version
RUN java --version

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . /app

# Ensure the Gradle wrapper script is executable
RUN chmod +x gradlew

# Defensive measure: Ensure gradle-wrapper.jar is available
RUN if [ ! -f gradle/wrapper/gradle-wrapper.jar ]; then \
        echo "Gradle Wrapper JAR is missing. Downloading..."; \
        mkdir -p gradle/wrapper && \
        curl -o gradle/wrapper/gradle-wrapper.jar \
        https://services.gradle.org/distributions/gradle-7.6-bin.zip; \
    fi

# Build the Spring Boot application
RUN ./gradlew bootjar --no-daemon

# Stage 2: Runtime Stage
FROM ubuntu:latest

# Install runtime dependencies
RUN apt-get update && apt-get install -y wget tar curl && \
    rm -rf /var/lib/apt/lists/*

# Copy the JDK from the build stage
COPY --from=build /usr/lib/jvm /usr/lib/jvm

# Set environment variables for JDK 23
ENV JAVA_HOME=/usr/lib/jvm/default-jdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Copy the built JAR from the build stage
COPY --from=build /app/build/libs/*.jar /app/app.jar

# Verify the Java version
RUN java --version

# Expose the application port
EXPOSE 8081

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
