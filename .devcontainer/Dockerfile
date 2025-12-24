# Dev container with LLVM, Clang, CMake, Ninja, Graphviz
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y wget gnupg lsb-release software-properties-common && \
    wget https://apt.llvm.org/llvm-snapshot.gpg.key -O /tmp/llvm.key && \
    apt-key add /tmp/llvm.key && \
    add-apt-repository "deb http://apt.llvm.org/$(lsb_release -cs)/ llvm-toolchain-$(lsb_release -cs)-17 main" && \
    apt-get update && \
    apt-get install -y \
      clang-17 llvm-17 llvm-17-dev lld-17 \
      cmake ninja-build build-essential \
      graphviz python3 python3-pip git && \
    ln -sf /usr/bin/clang-17 /usr/bin/clang && \
    ln -sf /usr/bin/opt-17 /usr/bin/opt && \
    ln -sf /usr/bin/llvm-dis-17 /usr/bin/llvm-dis && \
    useradd -ms /bin/bash vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER vscode
WORKDIR /workspaces
