# Multi stage building strategy for reducing image size.
# 変更点: 公式のGoイメージ（amd64互換）を直接使用
FROM golang:1.16.8-alpine3.13 AS build-env 
# FROM 233928981508.dkr.ecr.ap-northeast-1.amazonaws.com/oshima-handson-base:golang1.16.8-alpine3.13 AS build-env

ENV GO111MODULE=on
RUN mkdir /app
WORKDIR /app

# Install each dependencies
COPY go.mod /app
COPY go.sum /app
RUN go mod download

# 既にプロジェクトのDockerfileに存在するパッケージインストールコマンドはそのまま利用
RUN apk add --no-cache --virtual git gcc make build-base alpine-sdk

# COPY main module
COPY . /app

# Check and Build
RUN go get golang.org/x/lint/golint && \
    make validate && \
    make build-linux

### If use TLS connection in container, add ca-certificates following command.
### > RUN apk add --no-cache ca-certificates
FROM gcr.io/distroless/base-debian10
COPY --from=build-env /app/main /
EXPOSE 80
ENTRYPOINT ["/main"]