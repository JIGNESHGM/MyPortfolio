# Stage 1: Build Stage
FROM ubuntu:latest AS build

# Update and install dependencies
RUN apt-get update && apt-get install -y wget tar openjdk-17-jdk curl unzip

# Optional: Validate the OpenJDK 23 tar.gz file availability
RUN curl -fSL https://jdk.java.net/early-access/23/ga/binaries/openjdk-23_linux-x64_bin.tar.gz -o openjdk-23.tar.gz || \
    echo "OpenJDK 23 is unavailable; falling back to OpenJDK 17."

# Install OpenJDK 23 if available, else use OpenJDK 17
RUN if [ -f openjdk-23.tar.gz ]; then \
        mkdir -p /usr/lib/jvm && \
        tar -xvf openjdk-23.tar.gz -C /usr/lib/jvm && \
        rm openjdk-23.tar.gz && \
        ln -s /usr/lib/jvm/jdk-23 /usr/lib/jvm/default-jdk; \
    else \
        ln -s /usr/lib/jvm/java-17-openjdk-amd64 /usr/lib/jvm/default-jdk; \
    fi

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/default-jdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Verify the Java version
RUN java --version

# Copy project files and build
WORKDIR /app
COPY . /app
RUN ./gradlew bootjar --no-daemon

# Stage 2: Runtime Stage
FROM ubuntu:latest

# Copy JDK and application from build stage
COPY --from=build /usr/lib/jvm /usr/lib/jvm
COPY --from=build /app/build/libs/demo-1.jar /app/app.jar

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/default-jdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Verify the Java version again
RUN java --version

# Expose the application port
EXPOSE 8081

# Start the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

# Okay All Update