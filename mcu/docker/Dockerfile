# Use the official Ubuntu base image
FROM ubuntu:22.04

RUN echo 'root:asd' | chpasswd

COPY packages.txt /packages.txt

RUN apt update && apt install -y $(cat /packages.txt)

RUN apt install -y vim usbutils make

RUN groupadd dan
RUN useradd -ms /bin/bash dan-docker
RUN usermod -aG dan dan-docker
RUN usermod -aG plugdev dan-docker
RUN usermod -aG dialout dan-docker

USER dan-docker

WORKDIR /home/dan-docker

# Set the entry point to bash
ENTRYPOINT ["/bin/bash"]
