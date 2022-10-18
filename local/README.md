# Gateway Local Setup

Local setup for supply chain security gateway. Refer to [https://safedep.io/docs/getting-started/quickstart](https://safedep.io/docs/getting-started/quickstart) for detailed instructions

## Usage

```bash
docker-compose up -d
```

### Configuration

`config/gateway.json` is the source of truth for both gateway and envoy proxy configuration. When changed, envoy proxy configuration can be re-generated using:

```bash
docker pull ghcr.io/safedep/gateway && \
docker run -v `pwd`/config:/config:ro \
ghcr.io/safedep/gateway:latest \
confli -command generate-envoy -file /config/gateway.json > ./config/envoy.json
```

## Reference

* https://safedep.io/docs
* https://github.com/safedep/gateway
