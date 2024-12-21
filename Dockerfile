FROM golang:alpine AS builder

# Set the working directory inside the container
WORKDIR /src/app

COPY main.go ./

RUN go mod init notebook
RUN go get github.com/urfave/negroni
RUN go get github.com/gorilla/mux
RUN go get github.com/xyproto/simpleredis/v2

# Build the server binary
RUN go build -o server

FROM alpine:latest

WORKDIR /root/app

# Copy the built binary from the builder stage
COPY --from=builder /src/app/server .

# Copy public files
COPY ./public/index.html public/index.html
COPY ./public/script.js public/script.js
COPY ./public/style.css public/style.css

EXPOSE 3000
CMD ["./server"]