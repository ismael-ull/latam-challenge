# Use the official Golang image to create a build artifact.
# https://hub.docker.com/_/golang
FROM golang:1.17 AS builder

# Create and change to the app directory.
WORKDIR /app

# Copy go.mod and, if it exists, go.sum.
COPY go.mod ./
COPY go.sum* ./

# Retrieve application dependencies.
RUN go mod download

# Copy local code to the container image.
COPY . ./

# Build the binary.
# -o lc-app specifies the output file name, it should match the binary name in the CMD directive.
RUN CGO_ENABLED=0 GOOS=linux go build -v -o lc-api-go

# Use the official Debian slim image for a lean production container.
# https://hub.docker.com/_/debian
FROM debian:buster-slim
RUN set -x && apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/lc-api-go /lc-api-go

# Run the web service on container startup.
CMD ["/lc-api-go"]