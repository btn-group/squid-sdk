ARG node=node:16-alpine
FROM ${node} AS node


FROM node AS builder
RUN apk add g++ make python3
WORKDIR /squid
ADD . .
RUN node common/scripts/install-run-rush.js install
RUN node common/scripts/install-run-rush.js build


FROM builder AS substrate-dump-builder
RUN node common/scripts/install-run-rush.js deploy --project @subsquid/substrate-dump


FROM node AS substrate-dump
COPY --from=substrate-dump-builder /squid/common/deploy /squid
ENTRYPOINT ["node", "/squid/substrate/substrate-dump/bin/run.js"]


FROM builder AS chain-status-service-builder
RUN node common/scripts/install-run-rush.js deploy --project chain-status-service


FROM node AS chain-status-service
COPY --from=chain-status-service-builder /squid/common/deploy /squid
ENTRYPOINT ["node", "/squid/util/chain-status-service/lib/main.js"]
CMD ["/squid/util/chain-status-service/config.json"]
EXPOSE 3000
