# Use an official Ubuntu base image
FROM ubuntu:22.04

# Install dependencies
RUN apt update && apt install -y \
    g++ \
    make \
    cmake \
    git \
    wget \
    libhiredis-dev \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the source code
COPY src/main.cpp /app

# Compile the C++ application
RUN g++ -o my-app main.cpp -lhiredis -std=c++11

# Expose shared volume for leader election
VOLUME /shared

# Set environment variables (default values)
ENV REDIS_HOST=127.0.0.1
ENV REDIS_PORT=6379
ENV LEADER_KEY=leader
ENV LEASE_TIME=5
ENV POD_NAME=my-app

# Command to run the application
CMD ["/app/my-app"]
