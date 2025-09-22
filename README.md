# Crowdsec Benchmark

This docker stack can be used to benchmark an out-of-the-box crowdsec installation. It contains:

* [Traefik](https://doc.traefik.io/traefik/getting-started/install-traefik/) reverse proxy
  * Configured with [Access Logs](https://doc.traefik.io/traefik/observe/logs-and-access-logs/#access-logs) that Crowdsec can consume
  * Wired to serve [mendhak/http-https-echo](https://github.com/mendhak/docker-http-https-echo), a simple web server that accepts any paths and echos back the request as JSON
* [Crowdsec](https://docs.crowdsec.net/)
  * Configured to consume Traefik logs
  * With Collections required for parsing those logs and basic web traffic
* [k6](https://grafana.com/docs/k6/latest/) load testing tool
  * Configured to generate concurrent requests and duration of load using ENVs
  * Randomized path (`RANDOMIZE=true`)
  * Randomized User-Agent

Additionally, the bash script [`bench.sh`](/bench.sh) can be used to orchestrate the load call, monitor the crowdsec process, and create a .png plot of CPU using [`goeffel`](https://github.com/jgehrcke/goeffel), if it installed.

# Usage

## Create .env

Use the sample [`.env.example`](/.env.example) to create an `.env` for your scenario.

* `TARGET` = number of concurrent requests to make
* `DURATION` = number of seconds to run load
* `RANDOMIZE` = randomize url path
* `URL` = leave as default unless modifying this project for your own use

## Run Load

### Using `bench.sh`

Install latest development [`goeffel`](hhttps://github.com/jgehrcke/goeffel) version:

```shell
pipx install git+https://github.com/jgehrcke/goeffel
```

Run `bench.sh` from the project directory. It requires `sudo` to collect metrics.

```shell
sudo ./bench.sh
```

After the run has finished an image `[date]_crowdsec-web-traffic-load-[unix_timestamp].png` will be generated in the project directory.

Additional graphs can be plotted from the generated `hdf5` file using [`goeffel-analysis`](https://github.com/jgehrcke/goeffel?tab=readme-ov-file#goeffel-analysis-data-inspection-and-visualization).

### Manually

1. Start docker services required to run the load

```shell
docker compose up traefik echo crowdsec -d
```

2. Start any monitoring/profiling software for crowdsec

3. Run load

```shell
docker compose up k6
```

# Benchmark Results

See the [`bench-results`](/bench-results/) folder for some benchmarks run on my own hardware.