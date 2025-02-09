# Use a minimal C++ runtime image
FROM ubuntu:22.04

# Install dependencies
RUN apt update && apt install -y \
    g++ \
    make \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source code to container
COPY src/main.cpp .

# Compile C++ application
RUN g++ -o my-app main.cpp -std=c++11

# Expose shared volume for leader election
VOLUME /shared

# Run application
CMD ["/app/my-app"]
