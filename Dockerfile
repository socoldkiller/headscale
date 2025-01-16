
FROM golang:1.24rc1-alpine3.21 as stage

RUN apk update && \
    apk add bash  \
    curl  \
    gcc   \
    musl-dev  \
    git  && \
    curl -fsSL https://bun.sh/install | bash && \
    mv /root/.bun/bin/bun  /usr/local/bin/bun

COPY . /build/headscale

WORKDIR /build/headscale
# build frontend
RUN git clone https://github.com/socoldkiller/headscale-ui.git

WORKDIR /build/headscale/headscale-ui

RUN git checkout dev && \
    bun install  && \
    bun run build

WORKDIR /build/headscale

RUN cp -r headscale-ui/build/ hscontrol/

WORKDIR /build/headscale/cmd/headscale

RUN go build -ldflags="-s -w"


FROM alpine

COPY  --from=stage /build/headscale/cmd/headscale/headscale /usr/local/bin/headscale


CMD headscale serve
