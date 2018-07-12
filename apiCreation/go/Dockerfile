FROM golang:latest AS build-env
WORKDIR /src
RUN go get -v github.com/gorilla/mux github.com/globalsign/mgo
COPY src/ .
ENV CGO_ENABLED=0
RUN go build -o goapp
RUN go test

FROM alpine
WORKDIR /app
RUN apk update && apk add ca-certificates
EXPOSE 8081
COPY --from=build-env /src/goapp /app/
CMD ["./goapp"]
