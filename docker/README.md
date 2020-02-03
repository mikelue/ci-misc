This directory contains scripts and docker files used in CI environment.

## Docker files

## Scripts

`build-images.sh`

This script builds image by tagging **`<image>:latest`** and **`<image>:<tag>`** for every argument of repositories.

```bash
build-images.sh
	[-c] [-u <username>] [-p <password>]
	[-d 'docker options']
	[-t tag] <building path> <repository> [repository...]
```

Arguments:
- `-t <tag>`(default: `date +%y%m%d`)
	Tag of built images
- `-d <options>`
	Docker options(for `docker build <options>`)
	e.g., `-d '--build-arg v1=20'`
- `-c`
	If this argument is appeared in argument, the first <repository>:latest is tried to be pulled for cache
- `-u <username>`
	username for log-in to repository of cache
- `-p <token>`
	password(token) for log-in to repository of cache

Environment variables:
- `CACHE_REPOS_USERNAME` - Loaded by script, as same as `-u <username>`
- `CACHE_REPOS_TOKEN` - Loaded by script, as same as `-p <token>`

---

`push-images.sh`

This script push images for multiple tags of a image name

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
- Runs docker image with `--rm`
- `<workdir>`(of host's volume) is mounted and as the `--workdir` of container instance.

```bash
run-docker.sh [-d <docker options>] <image name:tag> <work dir> [commands ...]
```

Arguments:
- `-d <options>`
	Docker options fed to `docker run <options>`
