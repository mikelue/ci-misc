This directory contains scripts and docker files used in CI environment.

## Docker files

[cassandra-migrate](./cassandra-migrate/)

Base on [python:alpine](https://hub.docker.com/_/python), this image pre-installs [cassandra-migrate](https://github.com/Cobliteam/cassandra-migrate).

## Scripts

`build-images.sh`

Builds image by tagging **`<image>:latest`** and **`<image>:<tag>`** for every argument of repositories.

```bash
build-images.sh
	[-d 'docker options'] [-c <cache image>]
	[-t tag] <building path> <repository> [repository...]
```

Arguments:
- `-t <tag>`(default: `date +%y%m%d`)
	Tag of built images
- `-d <options>`
	Docker options(for `docker build <options>`)
	e.g., `-d '--build-arg v1=20'`
- `-c <cache image>`
	Pulls the cache image and applies `--cache-from <cache image>` into `docker build` command

---

`push-images.sh`

Pushes images for multiple tags of a image name

```bash
push-images.sh [-u <username>] [-p <password>]
	[-d 'docker options']
	<image name> <tag> [tag ...]
```

Arguments:
- `-d <options>`
	Docker options fed to `docker push <options>`
- `-u <username>`
	username for log-in to repository of cache
- `-p <token>`
	password(token) for log-in to repository of cache
- `-d <options>`
	Docker options(for `docker push <options>`)

Environment variables:
- `PUSH_REPOS_USERNAME` - Loaded by script, as same as `-u <username>`
- `PUSH_REPOS_TOKEN` - Loaded by script, as same as `-p <token>`

---

`run-docker.sh`

Runs docker image with some default arguments.

```bash
run-docker.sh [-d <docker options>] [-w <workdir>] [-v] <image name:tag> [commands ...]
```

**Default arguments** applied to [docker run](https://docs.docker.com/engine/reference/run/):
- `--rm --workdir /workdir`

**Default work directory:**

If `-w <workdir>`(of host's volume) is provided, it is mounted from the host's volume.

**Arguments:**
- `-d <options>`
	Docker options fed to `docker run <options>`
- `-w <workdir>`
	The value is mounted as `-v <workdir>:/workdir`
- `-v`
	Verbose

**Quoting:**

You must nested-quoting arguments of command if it contains special character of [default IFS](https://bash.cyberciti.biz/guide/$IFS):
```bash
run-docker.sh alpine:latest sh -c "'echo Hello World'"
```
