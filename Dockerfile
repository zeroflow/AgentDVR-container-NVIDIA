FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# Based on the works of LostKiwi1, updated to a newer version of AgentDVR / CUDA / ...
# https://www.reddit.com/r/ispyconnect/comments/omkq2c/dockerfile_for_agent_dvr_with_nvidia_decoding/

ARG URL_BINARIES="https://ispyfiles.azureedge.net/downloads/Agent_Linux64_4_7_6_0.zip"
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Austria/Vienna

# Download and install dependencies
RUN apt-get update \
    && apt-get install -y \
    wget unzip tzdata \
    libc6-dev software-properties-common \
    libjpeg-turbo8 libjpeg8 \
    libgdiplus

# Install .NET Runtime
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
    && chmod +x ./dotnet-install.sh \
    && ./dotnet-install.sh --version latest

# Install cybermax's ffmpeg with nvidia

# Set NVIDAI capabilities
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,video

# Download & Install Agent DVR
RUN wget -c ${URL_BINARIES} -O agent.zip \
    && unzip agent.zip -d /agent \
    && rm agent.zip

# Make agent executable
RUN chmod +x /agent/Agent

# Define default environment variables
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Main UI port
EXPOSE 8090

# TURN server port
EXPOSE 3478/udp

# TURN server UDP port range
EXPOSE 50000-50010/udp

# Data volumes
VOLUME ["/agent/Media/XML", "/agent/Media/WebServerRoot/Media", "/agent/Commands"]

# Define service entrypoint
CMD ["/agent/Agent"]