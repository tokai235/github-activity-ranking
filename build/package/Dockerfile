# see: https://hub.docker.com/_/golang
FROM golang:1.17.5

WORKDIR /go/app

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .

CMD go run cmd/main.go
