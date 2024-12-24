FROM ubuntu:latest AS build

# Update and install required dependencies
RUN apt-get update && apt-get install -y wget tar

# Download and install OpenJDK 23 (replace URL with actual JDK 23 if available)
RUN wget -O openjdk-23.tar.gz https://jdk.java.net/early-access/23/ga/binaries/openjdk-23_linux-x64_bin.tar.gz && \
    mkdir -p /usr/lib/jvm && \
    tar -xvf openjdk-23.tar.gz -C /usr/lib/jvm && \
    rm openjdk-23.tar.gz

# Set JAVA_HOME and update PATH
ENV JAVA_HOME=/usr/lib/jvm/jdk-23
ENV PATH=$JAVA_HOME/bin:$PATH

# Verify Java installation
RUN java --version

# Copy source code and build
COPY . .
RUN ./gradlew bootjar --no-daemon

FROM ubuntu:latest
# Use the same JDK in the runtime stage
COPY --from=build /usr/lib/jvm /usr/lib/jvm
ENV JAVA_HOME=/usr/lib/jvm/jdk-23
ENV PATH=$JAVA_HOME/bin:$PATH

EXPOSE 8081
COPY --from=build /build/libs/demo-1.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
