# Use the official Ubuntu base image
FROM ubuntu:22.04

COPY packages.txt /packages.txt

RUN echo 'root:asd' | chpasswd

RUN groupadd dan
RUN useradd -ms /bin/bash dan-docker
RUN usermod -aG dan dan-docker
RUN usermod -aG plugdev dan-docker
RUN usermod -aG dialout dan-docker

RUN echo 'PS1="\[\e[0;32m\]\u@\h:\[\e[0;34m\]\w\[\e[0m\]\$ "' >> /home/dan-docker/.bashrc

RUN apt update && apt install -y vim usbutils
RUN apt install -y $(cat /packages.txt)
RUN git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git /opt/riscv-toolchain

WORKDIR /opt/riscv-toolchain

RUN ./configure --prefix=/opt/riscv --with-arch=rv32gc --with-abi=ilp32
RUN make -j $(nproc)

WORKDIR /opt/riscv/bin

RUN chmod u+rwx ./*
RUN chmod g+rx ./*
RUN chmod o+r ./*

WORKDIR /usr/local/bin

RUN ln -s /opt/riscv/bin/* .


USER dan-docker

WORKDIR /home/dan-docker

# Set the entry point to bash
ENTRYPOINT ["/bin/bash"]
