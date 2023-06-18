# AgentDVR Container with NVidia Support

This container is based on [the previous works of LostKiwi1](https://www.reddit.com/r/ispyconnect/comments/omkq2c/dockerfile_for_agent_dvr_with_nvidia_decoding/
) and was updated to a newer version of AgentDVR, CUDA etc.

## Versions

* AgentDVR: 4.7.6.0
* CUDA: 12.1.1-runtime-ubuntu22.04
* .NET Runtime: latest (18.06.2023)

## Installing nvidia-docker2 on host system

Sourced from https://www.ibm.com/docs/de/maximo-vi/continuous-delivery?topic=planning-installing-docker-nvidia-docker2

    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt-get update
    sudo apt-get install nvidia-docker2
    sudo systemctl restart docker.service

To be able to run rootless containers with podman, we need the following configuration change to the NVIDIA runtime: [source](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#step-3-rootless-containers-setup)

    sudo sed -i 's/^#no-cgroups = false/no-cgroups = true/;' /etc/nvidia-container-runtime/config.toml


## Test nvidia runtime for docker

    docker run -it --rm --runtime=nvidia nvidia/cuda:12.1.1-runtime-ubuntu22.04 nvidia-smi

## docker-compose usage with deepstack

    version: "3.9"
    services:
    agentdvr:
        container_name: agentdvr
        restart: unless-stopped
        image: zeroflow/agentdvr-nvidia
        runtime: nvidia
        ports:
        - '8090:8090' # WebUI
        - '3478:3478/udp' # STUN
        - '50000-50010:50000-50010/udp'
        volumes:
        - /var/agent/config:/agent/Media/XML
        - /var/agent/media:/agent/Media/WebServerRoot/Media
        - /var/agent/commands:/agent/Commands
    deepstack:
        container_name: deepstack
        restart: unless-stopped
        image: deepquestai/deepstack
        ports:
        - '5000:5000'
        environment:
        - VISION-DETECTION=True