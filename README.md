# patroni-proxy

Simple proxy for a Consul-based [Patroni](https://github.com/zalando/patroni) deployment using [gobetween](https://github.com/yyyar/gobetween) as the proxy.

#### Why gobetween?

I run Patroni in [Nomad](https://nomadporject.io) and register my Postgres containers in Consul with two services, one for the Postgres listener and one for the Patroni API listener. gobetween makes it simple to use the SRV record for the Postgres port as the target, but health check the API service using a script.

The provided pg-check script uses the Patroni API to make sure the master and replica instances are available on the right ports.

## Usage

<details>
  <summary>Example Nomad config</summary>

```
task "patroni" {
  driver = "docker"

  template {
    source      = "/path/to/patroni.yml"
    destination = "secrets/patroni.yml"
  }

  config {
    image = "ccakes/nomad-pgsql-patroni:10.5-1"

    port_map {
      pg  = "$${NOMAD_PORT_pg}"
      api = "$${NOMAD_PORT_api}"
    }
  }

  service {
    name = "postgres"
    port = "pg"

    check {
      type     = "tcp"
      port     = "pg"
      interval = "10s"
      timeout  = "2s"
    }
  }

  service {
    name = "patroni-api"
    port = "api"
  }

  resources {
    memory = 2048

    network {
      port "api" {}
      port "pg" {}
    }
  }
}
```

</details>

Just run the Docker container and set `PATRONI_API` to the SRV record for the API service.

```
docker run -d --name postgres-proxy \
  -p 5432:5432 -p 5433:5433 \
  -e PATRONI_API=_patroni-api._tcp.service.consul \
  -v /path/to/example.toml:/etc/gobetween.toml \
  ccakes/patroni-proxy
```