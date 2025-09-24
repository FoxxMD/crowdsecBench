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
* forked [goeffel](https://github.com/FoxxMD/goeffel) for capturing process activity

Additionally, the bash script [`bench.sh`](/bench.sh) can be used to orchestrate the load call, monitor the crowdsec process, and create a .png plot of CPU using [`goeffel`](https://github.com/jgehrcke/goeffel).

# Usage

## Create .env

Use the sample [`.env.example`](/.env.example) to create an `.env` for your scenario.

* `TARGET` = number of concurrent requests to make per second
* `DURATION` = number of seconds to run load
* `RANDOMIZE` = randomize url path
* `URL` = leave as default unless modifying this project for your own use

## Run Load

### Using `bench.sh`

```shell
./bench.sh
```

After the run has finished an image `[date]_crowdsec-web-traffic-load-[unix_timestamp].png` will be generated in `./data/goeffel` directory.

Additional graphs can be plotted from the generated `hdf5` file using [`goeffel-analysis`](https://github.com/jgehrcke/goeffel?tab=readme-ov-file#goeffel-analysis-data-inspection-and-visualization).

### Manually

1. Start docker services required to run the load

```shell
docker compose up traefik echo crowdsec -d
```

2. Start any monitoring/profiling software for crowdsec

Using the goeffel container EX:

```shell
docker compose run --rm --no-TTY goeffel goeffel --pid MY_COOL_PROGRAM_PID
```

3. Run load

```shell
docker compose up k6
```

# Benchmark Results

See the [`bench-results`](/bench-results/) folder for some benchmarks run on my own hardware.