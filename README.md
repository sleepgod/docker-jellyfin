## Usage

Here are some example snippets to help you get started creating a container.

### docker-compose ([recommended](https://docs.linuxserver.io/general/docker-compose))

Compatible with docker-compose v2 schemas.

```yaml
----
version: "2.1"
services:
  jellyfin:
    image: linuxserver/jellyfin
    container_name: jellyfin
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - UMASK_SET=<022> #optional
    volumes:
      - /path/to/library:/config
      - /path/to/tvseries:/data/tvshows
      - /path/to/movies:/data/movies
      - /opt/vc/lib:/opt/vc/lib #optional
    ports:
      - 8096:8096
      - 8920:8920 #optional
      - 7359:7359/udp #optional
      - 1900:1900/udp #optional
    devices:
      - /dev/dri:/dev/dri #optional
      - /dev/vcsm:/dev/vcsm #optional
      - /dev/vchiq:/dev/vchiq #optional
      - /dev/video10:/dev/video10 #optional
      - /dev/video11:/dev/video11 #optional
      - /dev/video12:/dev/video12 #optional
    restart: unless-stopped
```

### docker cli

```
docker run -d \
  --name=jellyfin \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e UMASK_SET=<022> `#optional` \
  -p 8096:8096 \
  -p 8920:8920 `#optional` \
  -p 7359:7359/udp `#optional` \
  -p 1900:1900/udp `#optional` \
  -v /path/to/library:/config \
  -v /path/to/tvseries:/data/tvshows \
  -v /path/to/movies:/data/movies \
  -v /opt/vc/lib:/opt/vc/lib `#optional` \
  --device /dev/dri:/dev/dri `#optional` \
  --device /dev/vcsm:/dev/vcsm `#optional` \
  --device /dev/vchiq:/dev/vchiq `#optional` \
  --device /dev/video10:/dev/video10 `#optional` \
  --device /dev/video11:/dev/video11 `#optional` \
  --device /dev/video12:/dev/video12 `#optional` \
  --restart unless-stopped \
  linuxserver/jellyfin
```


## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8096` | Http webUI. |
| `-p 8920` | Optional - Https webUI (you need to set up your own certificate). |
| `-p 7359/udp` | Optional - Allows clients to discover Jellyfin on the local network. |
| `-p 1900/udp` | Optional - Service discovery used by DNLA and clients. |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London |
| `-e UMASK_SET=<022>` | for umask setting of Emby, default if left unset is 022. |
| `-v /config` | Jellyfin data storage location. *This can grow very large, 50gb+ is likely for a large collection.* |
| `-v /data/tvshows` | Media goes here. Add as many as needed e.g. `/data/movies`, `/data/tv`, etc. |
| `-v /data/movies` | Media goes here. Add as many as needed e.g. `/data/movies`, `/data/tv`, etc. |
| `-v /opt/vc/lib` | Path for Raspberry Pi OpenMAX libs *optional*. |
| `--device /dev/dri` | Only needed if you want to use your Intel GPU for hardware accelerated video encoding (vaapi). |
| `--device /dev/vcsm` | Only needed if you want to use your Raspberry Pi MMAL video decoding (Enabled as OpenMax H264 decode in gui settings). |
| `--device /dev/vchiq` | Only needed if you want to use your Raspberry Pi OpenMax video encoding. |
| `--device /dev/video10` | Only needed if you want to use your Raspberry Pi V4L2 video encoding. |
| `--device /dev/video11` | Only needed if you want to use your Raspberry Pi V4L2 video encoding. |
| `--device /dev/video12` | Only needed if you want to use your Raspberry Pi V4L2 video encoding. |

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```
-e FILE__PASSWORD=/run/secrets/mysecretpassword
```

Will set the environment variable `PASSWORD` based on the contents of the `/run/secrets/mysecretpassword` file.

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## Optional Parameters

The [official documentation for ports](https://jellyfin.org/docs/general/networking/index.html) has additional ports that can provide auto discovery.

Service Discovery (`1900/udp`) - Since client auto-discover would break if this option were configurable, you cannot change this in the settings at this time. DLNA also uses this port and is required to be in the local subnet.

Client Discovery (`7359/udp`) - Allows clients to discover Jellyfin on the local network. A broadcast message to this port with "Who is Jellyfin Server?" will get a JSON response that includes the server address, ID, and name.

```
  -p 7359:7359/udp \
  -p 1900:1900/udp \
```


## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```


&nbsp;
## Application Setup

Webui can be found at `http://<your-ip>:8096`

More information can be found in their official documentation [here](https://jellyfin.org/docs/general/quick-start.html) .

## Hardware Acceleration

### Intel

Hardware acceleration users for Intel Quicksync will need to mount their /dev/dri video device inside of the container by passing the following command when running or creating the container:

`--device=/dev/dri:/dev/dri`

We will automatically ensure the abc user inside of the container has the proper permissions to access this device.

### Nvidia

Hardware acceleration users for Nvidia will need to install the container runtime provided by Nvidia on their host, instructions can be found here:

https://github.com/NVIDIA/nvidia-docker

We automatically add the necessary environment variable that will utilise all the features available on a GPU on the host. Once nvidia-docker is installed on your host you will need to re/create the docker container with the nvidia container runtime `--runtime=nvidia` and add an environment variable `-e NVIDIA_VISIBLE_DEVICES=all` (can also be set to a specific gpu's UUID, this can be discovered by running `nvidia-smi --query-gpu=gpu_name,gpu_uuid --format=csv` ). NVIDIA automatically mounts the GPU and drivers from your host into the jellyfin docker container.

### OpenMAX (Raspberry Pi)

Hardware acceleration users for Raspberry Pi MMAL/OpenMAX will need to mount their `/dev/vcsm` and `/dev/vchiq` video devices inside of the container and their system OpenMax libs by passing the following options when running or creating the container:

```
--device=/dev/vcsm:/dev/vcsm
--device=/dev/vchiq:/dev/vchiq
-v /opt/vc/lib:/opt/vc/lib
```

### V4L2 (Raspberry Pi)

Hardware acceleration users for Raspberry Pi V4L2 will need to mount their `/dev/video1X` devices inside of the container by passing the following options when running or creating the container:

```
--device=/dev/video10:/dev/video10
--device=/dev/video11:/dev/video11
--device=/dev/video12:/dev/video12
```


## Docker Mods
[![Docker Mods](https://img.shields.io/badge/dynamic/yaml?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=jellyfin&query=%24.mods%5B%27jellyfin%27%5D.mod_count&url=https%3A%2F%2Fraw.githubusercontent.com%2Flinuxserver%2Fdocker-mods%2Fmaster%2Fmod-list.yml)](https://mods.linuxserver.io/?mod=jellyfin "view available mods for this container.") [![Docker Universal Mods](https://img.shields.io/badge/dynamic/yaml?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=universal&query=%24.mods%5B%27universal%27%5D.mod_count&url=https%3A%2F%2Fraw.githubusercontent.com%2Flinuxserver%2Fdocker-mods%2Fmaster%2Fmod-list.yml)](https://mods.linuxserver.io/?mod=universal "view available universal mods.")

We publish various [Docker Mods](https://github.com/linuxserver/docker-mods) to enable additional functionality within the containers. The list of Mods available for this image (if any) as well as universal mods that can be applied to any one of our images can be accessed via the dynamic badges above.


## Support Info

* Shell access whilst the container is running: `docker exec -it jellyfin /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f jellyfin`
* container version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' jellyfin`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/jellyfin`

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (ie. nextcloud, plex), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.

Below are the instructions for updating containers:

### Via Docker Compose
* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull jellyfin`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d jellyfin`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run
* Update the image: `docker pull linuxserver/jellyfin`
* Stop the running container: `docker stop jellyfin`
* Delete the container: `docker rm jellyfin`
* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `docker image prune`

### Via Watchtower auto-updater (only use if you don't remember the original parameters)
* Pull the latest image at its tag and replace it with the same env variables in one run:
  ```
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once jellyfin
  ```
* You can also remove the old dangling images: `docker image prune`

**Note:** We do not endorse the use of Watchtower as a solution to automated updates of existing Docker containers. In fact we generally discourage automated updates. However, this is a useful tool for one-time manual updates of containers where you have forgotten the original parameters. In the long term, we highly recommend using [Docker Compose](https://docs.linuxserver.io/general/docker-compose).

### Image Update Notifications - Diun (Docker Image Update Notifier)
* We recommend [Diun](https://crazymax.dev/diun/) for update notifications. Other tools that automatically update containers unattended are not recommended or supported.

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:
```
git clone https://github.com/linuxserver/docker-jellyfin.git
cd docker-jellyfin
docker build \
  --no-cache \
  --pull \
  -t linuxserver/jellyfin:latest .
```

The ARM variants can be built on x86_64 hardware using `multiarch/qemu-user-static`
```
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```

Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`.

## Versions

* **22.07.20:** - Ingest releases from Jellyfin repo.
* **28.04.20:** - Replace MMAL/OMX dependency device `/dev/vc-mem` with `/dev/vcsm` as the former was not sufficient for raspbian.
* **11.04.20:** - Enable hw decode (mmal) on Raspberry Pi, update readme instructions, add donation info, create missing default transcodes folder.
* **11.03.20:** - Add Pi V4L2 support, remove optional transcode mapping (location is selected in the gui, defaults to path under `/config`).
* **30.01.20:** - Add nightly tag.
* **09.01.20:** - Add Pi OpenMax support.
* **02.10.19:** - Improve permission fixing for render & dvb devices.
* **31.07.19:** - Add AMD drivers for vaapi support on x86.
* **13.06.19:** - Add Intel drivers for vaapi support on x86.
* **07.06.19:** - Initial release.
